# Flows

[![Build Status](https://travis-ci.com/ffloyd/flows.svg?branch=master)](https://travis-ci.com/ffloyd/flows)
[![codecov](https://codecov.io/gh/ffloyd/flows/branch/master/graph/badge.svg)](https://codecov.io/gh/ffloyd/flows)
[![Gem Version](https://badge.fury.io/rb/flows.svg)](https://badge.fury.io/rb/flows)

Small and fast ruby framework for implementing railway-like operations.
By design it is close to [Trailblazer::Operation](http://trailblazer.to/gems/operation/2.0/) and [Dry::Transaction](https://dry-rb.org/gems/dry-transaction/),
but has simpler and flexible DSLs for defining operations and matching results. Also `flows` is faster, see [Performance](overview/performance.md).

`flows` has no production dependencies so it can be used with any framework.

## Flows::Result

Wrap your data into Result Objects and use convinient matchers for making decisions:

```ruby
class Example
  include Flows::Result::Helpers

  def divide(a, b)
    return err(:zero_division, msg: 'Division by zero is forbidden') if b.zero?

    result = a / b

    if result.negative?
      ok(:negative, div: result)
    else
      ok(:positive, div: result)
    end
  end

  def dispatch(result)
    case result
    when match_ok(:positive)
      puts 'Positive result: ' + result.unwrap[:div]
    when match_ok(:negative)
      puts 'Negative result: ' + result.unwrap[:div]
    when match_err
      raise result.error[:msg]
    end
  end
end

example = Example.new

result = example.divide(4, 2)

example.dispatch(result) # => Positive result: 2
```

Features:

* different classes for successful and failure results (`Flows::Result::Ok` and `Flows::Result::Err`)
* each result has status (`:positive`, `:negative` and `:zero_division` in the provided example are result statuses)
* convinient helpers for creating and matching Result Objects (`#ok`, `#err`, `#math_ok`, `#match_err`)
* defferent data accessor for successful (`#unwrap`) and failure (`#error`) results (prevents traiting failure objects as successful ones)
* Do-notation (like [this one](https://dry-rb.org/gems/dry-monads/1.0/do-notation/) but with a bit [richer API](result_objects/do_notation.md))
* result has metadata - this may be used for storing execution metadata (execution time, for example, or something for good error reporting)

More details in a [Result Object Basic Usage Guide](result_objects/basic_usage.md).

## Flows::Railway

Organize subsequent data tranformations (result of a step becomes input for a next step or a final result):

```ruby
class ExampleRailway
  include Flows::Railway

  step :validate
  step :add_10
  step :mul_2

  def validate(x:)
    return err(:invalid_type, msg: 'Invalid argument type') unless x.is_a?(Numeric)

    ok(x: x)
  end

  def add_10(x:)
    ok(x: x + 10)
  end

  def mul_2(x:)
    ok(x: x * 2)
  end
end

example = ExampleRailway.new

example.call(x: 2)
# => Flows::Result::Ok with data `{x: 24}`

example.call(x: 'invalid')
# => Flows::Result::Err with status `:invalid_type` and data `msg: 'Invalid argument type'`
# methods `#add_10` and `#mul_2` not even executed
# because Railway stops execution on a first failure result
```

Features:

* Good composition: `Railway` returns Result Object, step returns Result Object - so you may easily extract steps into separate `Railway`, etc.
* Support for inheritance (child class may redefine steps or append new steps to the end of flow)
* Less runtime overhead than in `Flows::Operaion`
* Override steps implementations using dependency injection on initialization (`.new(deps: {...})`)

More details in a [Railway Basic Usage Guide](railway/basic_usage.md).

## Flows::Operation

If you can express your business logic in BPMN - you can code it using Operations:

```ruby
class ExampleOperation
  include Flows::Operation

  step :fetch_facebook_profile, routes(when_err => :handle_fetch_error)
  step :fetch_twitter_profile, routes(when_err => :handle_fetch_error)
  step :extract_person_data

  track :handle_fetch_error do
    step :track_fetch_error
    step :make_fetch_error
  end

  ok_shape :person
  err_shape :message

  def fetch_facebook_profile(email:, **)
    result = some_fb_fetcher(email)
    return err unless result

    ok(facebook_data: result)
  end

  def fetch_twitter_profile(email:, **)
    result = some_twitter_fetcher(email)
    return err unless result

    ok(twitter_data: result)
  end

  def extract_person_data(facebook_data:, twitter_data:, **)
    ok(person: facebook_data.merge(twitter_data))
  end

  def track_fetch_error(**)
    # send event to New Relic, etc.
    ok
  end

  def make_fetch_error(**)
    err(:fetch_error, message: 'Fetch error')
  end
end

operation = ExampleOperation.new

operation.call(email: 'whatever@email.com')
```

Features:

* Superset of `Railway` - any Railway can be converted into Operation in a seconds
* Result Shaping - return only data you need
* Branching and Tracks - you may do even loops if you brave enough
* Good Composition - cause everything here returns Result Objects and receives keyword argumets (or hash) you may compose Operations and Railways without any additional effort. Generally speaking - Railway is an simplified operation.

More details in a [Operation Basic Usage Guide](operation/basic_usage.md).

## Flows::Flow

Railway and Operation use `Flows::Flow` under the hood to transform your step definitions into executable workflow.
It's not recommended to use Flow in your business code but it's a good tool for building your own abstractions in yours libraries.

More details [here](flow/general_idea.md).
