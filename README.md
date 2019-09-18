# Flows

[![Build Status](https://github.com/ffloyd/flows/workflows/Build/badge.svg)](https://github.com/ffloyd/flows/actions)
[![codecov](https://codecov.io/gh/ffloyd/flows/branch/master/graph/badge.svg)](https://codecov.io/gh/ffloyd/flows)
[![Gem Version](https://badge.fury.io/rb/flows.svg)](https://badge.fury.io/rb/flows)

Small and fast ruby framework for implementing railway-like operations.
By design it is close to [Trailblazer::Operation](http://trailblazer.to/gems/operation/2.0/) and [Dry::Transaction](https://dry-rb.org/gems/dry-transaction/),
but has simpler and flexible DSL for defining operations and matching results. Also `flows` is faster, see [Performance](#performance).

`flows` has no production dependencies so it can be used with any framework.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flows'
```

And then execute:

```sh
bundle
```

Or install it yourself as:

```sh
gem install flows
```

## Usage

### `Flows::Flow`

Low-level instrument for defining execution flows. Used internally as execution engine for `Flows::Operation`.
Check out source code and specs for details.

### `Flows::Result`

Result Object implementation. Inspired by [Dry::Monads::Result](https://dry-rb.org/gems/dry-monads/1.0/result/) and
[Rust Result Objects](https://doc.rust-lang.org/1.30.0/book/2018-edition/ch09-02-recoverable-errors-with-result.html).

Main concepts & conventions:

* separate classes for successful (`Flows::Result::Ok`) and failure (`Flows::Result::Err`) results
  * both classes has same parent class `Flows::Result`
* result data should be a `Hash` with symbol keys and any values
* result has a status
  * default status for successful results is `:success`
  * default status for failure results is `:failure`

Basic usage:

```ruby
# create successful result with data {a: 1, b: 2}
result_ok = Flows::Result::Ok.new(a: 1, b: 2)

# get `:a` from result
result_ok.unwrap[:a] # 1

# get error data from result
result_ok.error[:a] # raises exception

# get status from result
result_ok.status # :success

# boolean flags
result_ok.ok? # true
result_ok.err? # false

# create successful result with data {a: 1, b: 2} and status `:custom`
result_ok_custom = Flows::Result::Ok.new({ a: 1, b: 2 }, status: :custom)

# get status from result
result_ok_custom.status # :custom

# create failure result with data {a: 1, b: 2}
result_err = Flows::Result::Err.new(a: 1, b: 2)

# get `:a` from result
result_err.unwrap[:a] # raises exception

# get error data from result
result_err.error[:a] # 1

# get status from result
result_err.status # :failure

# boolean flags
result_ok.ok? # false
result_ok.err? # true

# create failure result with data {a: 1, b: 2} and status `:custom`
result_err_custom = Flows::Result::Err.new({ a: 1, b: 2 }, status: :custom)

# get status from result
result_err_custom.status # :custom
```

Mixin `Flows::Result::Helpers` contains tools for simpler generating and matching Result Objects:

```ruby
include Flows::Result::Helpers

# create successful result with data {a: 1, b: 2}
result_ok = ok(a: 1, b: 2)

# create successful result with data {a: 1, b: 2} and status `:custom`
result_ok_custom = ok(:custom, a: 1, b: 2)

# create failure result with data {a: 1, b: 2}
result_err = err(a: 1, b: 2)

# create failure result with data {a: 1, b: 2} and status `:custom`
result_err_custom = err(:custom, a: 1, b: 2)

# matching helpers
result = SomeOperation.new.call

case result
when match_ok(:custom)
  # matches only successful results with status :custom
  do_something
when match_ok
  # matches only successful results with any status
  do_something
when match_err(:custom)
  # matches only failure results with status :custom
  do_something
when match_err
  # matches only failure results with any status
  do_something
end
```

### `Flows::Operation`

Let's solve simple task using operation:

* given numbers `a` and `b`
* result should contain sum of this numbers
* result should contain square of this sum

```ruby
class Summator
  # Make this class an operation by including this module.
  # It adds DSL, initializer and call method.
  # Also it includes Flows::Result::Helper both on DSL and instance level.
  include Flows::Operation

  # This is step definitions.
  # In simplest form step defined by its name and
  # step implementation expected to be in a method
  # with same name.
  #
  # Steps will be executed in a definition order.
  step :validate
  step :calc_sum
  step :calc_square

  # Which keys of operation data we want to expose on success
  ok_shape :sum, :sum_square

  # Which keys of operation data we want to expose on failure
  err_shape :message

  # Step implementation receives execution context as keyword arguments.
  # For the first step context equals to operation arguments.
  #
  # Step implementation must return Result Object.
  # Result Objects's data will be merged into operation context.
  #
  # If result is successful - next step will be executed.
  # If not - operation terminates and returns failure.
  def validate(a:, b:, **)
    err(message: 'a is not a number') unless a.is_a?(Number)
    err(message: 'b is not a number') unless b.is_a?(Number)

    ok
  end

  def calc_sum(a:, b:, **)
    ok(sum: a + b)
  end

  # We may get data from previous steps because all results' data are merged to context.
  def calc_square(sum:, **)
    ok(sum_square: sum * sum)
  end
end

# prepare operation
operation = Summator.new

# execute operation
result = operation.call(a: 1, b: 2)

result.ok? # true
result.unwrap # { sum: 3, sum_square: 9 } - only keys from success shape present

result = operation.call(a: nil, b: nil)

result.ok? # false
result.error # { message: 'a is not a number' } - only keys from error shape present
```

#### Result Shapes

You may limit list of exposed fields by defining success and failure shapes. _After_ step definitions use `ok_shape` to define shapes of success result, and `err_shape` to define shapes of failure result. Examples:

```ruby
# Set exposed keys for :success status of successful result.
#
# Success result will have shape like { key1: ..., key2: ... }
#
# If one of keys is missing in the final operation context an exception will be raised.
ok_shape :key1, :key2

# Set different exposed keys for different statuses.
#
# Operation result status is a status of last executed step result.
ok_shape status1: %i[key1 key2],
         status2: [:key3]

# Failure shapes defined in the same way:
err_shape :key1, :key2
err_shape status1: %i[key1 key2],
          status2: [:key3]
```

Operation definition should have exact one `ok_shape` DSL-call and zero or one `err_shape` DSL-call. If you want to disable shaping
you can write `no_shape` DSL-call instead of shape definitions.

#### Routing & Tracks

You define side tracks, even nested ones:

```ruby
step :outer_1 # next step is outer_2

track :some_track do
  step :inner_1 # next step is inner_2
  track :inner_track do
    step :deep_1 # next step is deep_2
    step :deep_2 # next step is inner_2
  end
  step :inner_2 # next step in outer_2
end

step :outer_2
```

In definition above tracks will not be used because there is no routes to this tracks. You may define routing like this:

```ruby
# if result is successful and has status :to_some_track - next step will be inner_1
# for any other successful results - outer_2
step :outer_1, routes(
  when_ok(:to_some_track) => :some_track
)

track :some_track do
  step :inner * 1, routes(when_err => :inner_track) # redirect to inner_track on any failure result
  track :inner_track do
    step :deep_1, routes(when_ok(:some_status) => :outer_2) # you may redirect to steps too
    step :deep_2
  end
  step :inner_2
end

step :outer_2
```

You also can use less verbose, but shorter form of definition:

```ruby
step :name,
     match_ok(:status) => :track_name,
     match_ok => :track_name
```

Step has default routes:

```ruby
routes(
  when_ok => next_step_name,
  when_err => :term
)
```

Custom routes have bigger priority than default ones. Moreover, default routes can be overriden.

#### Lambda Steps

You can use lambda for in-place step implementation:

```ruby
step :name, ->(a:, b:, **) { ok(sum: a + b) }
```

#### Dependency Injection

You can override or inject step implementation on initialization:

```ruby
class Summator
  include Flows::Operation

  step :sum

  ok_shape :sum
end

summator = Summator.new(deps: {
                          sum: ->(a:, b:, **) { ok(sum: a + b) }
                        })

summator.call(a: 1, b: 2).unwrap[:sum] # 3
```

#### Wrapping steps

You can wrap several steps with some logic:

```ruby
step :first

wrap :wrapper do
  step :wrapped
end

def wrapper(**_context)
  # do smth
  result = yield # execute wrapped steps
  # do smth or modify result
  result
end
```

There is routing limitation when you use wrap:

* outside `wrap` block you may route to wrapped block by wrapper name (`:wrapper` in the provided example)
* you may route wrapped steps only to wrapped steps in the same wrap block
* you cannot route to wrapped steps from outside

## Performance

You can compare performance for some cases by executing `bin/benchmark`. Examples for benchmark are presented in `bin/examples.rb`.

`Flows::Operation` and `Dry::Trancation` may be executed in two ways:

_Build once:_ when we create operation instance once (build operation):

```ruby
operation = OperationClass.new

10_000.times { operation.call }
```

_Build each time:_ when we create operation instance each execution:

```ruby
10_000.times { OperationClass.new.call }
```

`flows` and `dry` are much faster in _build once_ way of using. Note that Trailblazer gives you only one way to execute operation.

### Benchmark Results

Host:

* MacBook Pro (13-inch, 2017, Four Thunderbolt 3 Ports)
* 3.1 GHz Intel Core i5
* 8 GB 2133 MHz LPDDR3

Results:

```text
--------------------------------------------------
- task: A + B, one step implementation
--------------------------------------------------
Warming up --------------------------------------
Flows::Operation (build each time)
                         9.147k i/100ms
Flows::Operation (build once)
                        25.738k i/100ms
Dry::Transaction (build each time)
                         2.294k i/100ms
Dry::Transaction (build once)
                        21.836k i/100ms
Trailblazer::Operation
                         5.057k i/100ms
Calculating -------------------------------------
Flows::Operation (build each time)
                         96.095k (± 2.3%) i/s -    484.791k in   5.047684s
Flows::Operation (build once)
                        281.248k (± 1.7%) i/s -      1.416M in   5.034728s
Dry::Transaction (build each time)
                         23.683k (± 1.7%) i/s -    119.288k in   5.038506s
Dry::Transaction (build once)
                        237.379k (± 3.3%) i/s -      1.201M in   5.066073s
Trailblazer::Operation
                         52.676k (± 1.5%) i/s -    268.021k in   5.089306s

Comparison:
Flows::Operation (build once):   281248.4 i/s
Dry::Transaction (build once):   237378.7 i/s - 1.18x  slower
Flows::Operation (build each time):    96094.9 i/s - 2.93x  slower
Trailblazer::Operation:    52676.3 i/s - 5.34x  slower
Dry::Transaction (build each time):    23682.9 i/s - 11.88x  slower


--------------------------------------------------
- task: ten steps returns successful result
--------------------------------------------------
Warming up --------------------------------------
Flows::Operation (build each time)
                         1.496k i/100ms
Flows::Operation (build once)
                         3.847k i/100ms
Dry::Transaction (build each time)
                       274.000  i/100ms
Dry::Transaction (build once)
                         2.992k i/100ms
Trailblazer::Operation
                         1.082k i/100ms
Calculating -------------------------------------
Flows::Operation (build each time)
                         15.013k (± 3.8%) i/s -     76.296k in   5.089734s
Flows::Operation (build once)
                         39.239k (± 1.6%) i/s -    196.197k in   5.001538s
Dry::Transaction (build each time)
                          2.743k (± 3.7%) i/s -     13.700k in   5.002847s
Dry::Transaction (build once)
                         30.441k (± 1.8%) i/s -    152.592k in   5.014565s
Trailblazer::Operation
                         11.022k (± 1.4%) i/s -     55.182k in   5.007543s

Comparison:
Flows::Operation (build once):    39238.6 i/s
Dry::Transaction (build once):    30440.5 i/s - 1.29x  slower
Flows::Operation (build each time):    15012.7 i/s - 2.61x  slower
Trailblazer::Operation:    11022.1 i/s - 3.56x  slower
Dry::Transaction (build each time):     2743.0 i/s - 14.30x  slower
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at [ffloyd/fflows](https://github.com/ffloyd/flows). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Flows project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ffloyd/flows/blob/master/CODE_OF_CONDUCT.md).
