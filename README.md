# Flows

[![Build Status](https://travis-ci.com/ffloyd/flows.svg?branch=master)](https://travis-ci.com/ffloyd/flows)
[![codecov](https://codecov.io/gh/ffloyd/flows/branch/master/graph/badge.svg)](https://codecov.io/gh/ffloyd/flows)
[![Gem Version](https://badge.fury.io/rb/flows.svg)](https://badge.fury.io/rb/flows)

Small and fast ruby framework for implementing railway-like operations.
By design it close to [Trailblazer::Operation](http://trailblazer.to/gems/operation/2.0/) and [Dry::Transaction](https://dry-rb.org/gems/dry-transaction/),
but has more simpler and flexible DSL for defining operations and matching results. Also `flows` is significantly faster.

`flows` has no production dependencies so you can use it with any framework.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flows'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install flows

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
result_ok = Flows::Result::Ok.new(a:1, b: 2)

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
result_err = Flows::Result::Err.new(a:1, b: 2)

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
result_ok = ok(a:1, b: 2)

# create successful result with data {a: 1, b: 2} and status `:custom`
result_ok_custom = ok(:custom, a: 1, b: 2)

# create failure result with data {a: 1, b: 2}
result_err = err(a:1, b: 2)

# create failure result with data {a: 1, b: 2} and status `:custom`
result_err_custom = err(:custom, a: 1, b: 2)

# matching helpers
result = ...

case result
when match_ok(:custom)
  # matches only successful results with status :custom
when match_ok
  # matches only successful results with any status
when match_err(:custom)
  # matches only failure results with status :custom
when match_err
  # matches only failure results with any status
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
  success :sum, :sum_square
  
  # Which keys of operation data we want to expose on failure 
  failure :message
  
  # Step implementation receives execution context as keyword arguments.
  # For the first step context equals to operation arguments.
  #
  # Step implementation must return Result Object.
  # Result Objects's data will be merged into operation context.
  # 
  # If result is successful - next step will be executed.
  # If not - operation terminates and returns failure.
  def validate(a:, b:, **)
    err(message: 'a is not a number') if !a.is_a?(Number)
    err(message: 'b is not a number') if !b.is_a?(Number)
    
    ok
  end
  
  def calc_sum(a:, b:, **)
    ok(sum: a + b)
  end
  
  # We may get data from previous steps because all results' data are merged to context.
  def calc_square(sum:, **)
    ok(sum_square: a * b)
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

You may limit list of exposed fields by defining success and failure shapes. _After_ step definitions use `success` to define shapes of success result,
and `failure` to define shapes of failure result. Examples:

```ruby
# Set exposed keys for :success status of successful result.
#
# Success result will have shape like { key1: ..., key2: ... }
#
# If one of keys is missing in the final operation context an exception will be raised.
success :key1, :key2

# Set different exposed keys for different statuses.
#
# Operation result status is a status of last executed step result.
success status1: [:key1, :key2],
        status2: [:key3]
        
# Failure shapes defined in the same way:
failure :key1, :key2
failure status1: [:key1, :key2],
        status2: [:key3]
```

Operation definition should have exact one `success` DSL-call and zero or one `failure` DSL-call. If you want to disable shaping
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
step :outer_1,
  match_ok(:to_some_track) => :some_track

track :some_track do
  step :inner_1, match_err => :inner_track # redirect to inner_track on failure result
  track :inner_track do
    step :deep_1, match_ok(:some_status) => :outer_2 # you may redirect to steps too
    step :deep_2
  end
  step :inner_2
end

step :outer_2
```

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
  
  success :sum
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

def wrapper(**context)
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ffloyd/flows. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Flows project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ffloyd/flows/blob/master/CODE_OF_CONDUCT.md).
