module Flows
  # Result Object is a way of presenting the result of a calculation. The result may be successful or failed.
  #
  # For example, if you calculate expression `a / b`:
  #
  # * for `a = 6` and `b = 2` result will be successful with data `3`.
  # * for `a = 6` and `b = 0` result will be failed with data, for example, `"Cannot divide by zero"`.
  #
  # Examples of such approach may be found in other libraries and languages:
  #
  # * [Either Monad](https://hackage.haskell.org/package/category-extras-0.52.0/docs/Control-Monad-Either.html)
  #   in Haskell.
  # * [Result Type](https://doc.rust-lang.org/std/result/enum.Result.html) in Rust.
  # * [Faraday gem](https://www.rubydoc.info/gems/faraday/Faraday/Response) has `Faraday::Response` object
  #   which contains data and status.
  # * [dry-rb Result Monad](https://dry-rb.org/gems/dry-monads/1.3/result/) has `Dry::Monads::Result`.
  #
  # So, why do you need Result Object?
  # Why not just return `nil` on a failure or raise an error (like in the standard library)?
  # Here are several reasons:
  #
  # * Raising errors and exceptions is a [bad way](https://martinfowler.com/articles/replaceThrowWithNotification.html)
  #   of handling errors.
  #   Moreover, it is slow and looks like `goto`.
  #   However, it is still a good way to abort execution on an unexpected error.
  # * Returning `nil` does not work when you have to deal with different types of errors or
  #   an error has some data payload.
  # * Using specific Result Objects (like `Faraday::Response`) brings inconsistency -
  #   you have to learn how to deal with each new type of Result.
  #
  # That's why `Flows` should have Result Object implementation.
  # If any executable Flows entity will return Result Object with the same API -
  # composing your app components becomes trivial.
  # Result Objects should also be as fast and lightweight as possible.
  #
  # Flows' implementation is inspired mainly by [Rust Result Type](https://doc.rust-lang.org/std/result/enum.Result.html)
  # and focused on following features:
  #
  # * Use idiomatic Ruby: no methods named with first capital letter (`Name(1, 2)`), etc.
  # * Use `case` and `===` (case equality) for matching results and writing routing logic.
  # * Provide helpers for convenient creation and matching of Result Objects ({Helpers}).
  # * Result Object may be successful ({Ok}) or failure ({Err}).
  # * Result Object has an {#status} (some symbol: `:saved`, `:zero_division_error`).
  # * Status usage is optional. Default statuses for successful and failure results are `:ok` and `:err`.
  # * Result may have metadata ({#meta}).
  #   Metadata is something unrelated to your business logic
  #   (execution time, for example, or some info about who created this result).
  #   This data must not be used in business logic, it's for a library code.
  # * Different accessors for successful and failure results -
  #   prevents treating failure results as successful and vice versa.
  #
  # ## General Recommendations
  #
  # Let's assume that you have some code returning Result Object.
  #
  # * if an error happened and may be handled somehow - return failure result.
  # * if an error happened and cannot be handled - raise exception to abort execution.
  # * if you don't handle any errors for now - don't check result type and
  #   use {#unwrap} to access data. It will raise exception when called on a failure result.
  #
  # @example Creating Result Objects
  #   # Successful result with data {a: 1}
  #   x = Flows::Result::Ok.new(a: 1)
  #
  #   # Failure result with data {msg: 'error'}
  #   x = Flows::Result::Err.new(msg: 'error')
  #
  #   # Successful result with data {a: 1} and status `:done`
  #   x = Flows::Result::Ok.new({ a: 1 }, status: :done)
  #
  #   # Failure result with data {msg: 'error'} and status `:http_error`
  #   x = Flows::Result::Err.new({ msg: 'error' }, status: :http_error)
  #
  #   # Successful result with data {a: 1} and metadata { time: 123 }
  #   x = Flows::Result::Ok.new({ a: 1 }, meta: { time: 123 })
  #
  #   # Failure result with data {msg: 'error'} and metadata { time: 123 }
  #   x = Flows::Result::Err.new({ msg: 'error' }, meta: { time: 123 })
  #
  # @example Create Result Objects using helpers
  #   class Demo
  #     # You cannot provide metadata using helpers and it's ok:
  #     # you shouldn't populate metadata in your business code.
  #     # Metadata is designed to use in library code and
  #     # when you have to provide some metadata from your library -
  #     # just use `.new` instead of helpers.
  #     include Flows::Result::Helpers
  #
  #     def demo
  #       # Successful result with data {a: 1}
  #       x = ok(a: 1)
  #
  #       # Failure result with data {msg: 'error'}
  #       x = err(msg: 'error')
  #
  #       # Successful result with data {a: 1} and status `:done`
  #       x = ok(:done, a: 1)
  #
  #       # Failure result with data {msg: 'error'} and status `:http_error`
  #       x = err(:http_error, msg: 'error')
  #     end
  #   end
  #
  # @example Inspecting Result Objects
  #   # Behaviour of any result object:
  #   result.status # returns status, example: `:ok`
  #   result.meta # returns metadata, example: `{}`
  #
  #   # Behaviour specific to successful results:
  #   result.ok? # true
  #   result.err? # false
  #   result.unwrap # returns result data
  #   result.error # raises exception
  #
  #   # Behaviour specific to failure results:
  #   result.ok? # false
  #   result.err? # true
  #   result.unwrap # raises exception
  #   result.error # returns result data
  #
  # @example Matching Results with case
  #   case result
  #   when Flows::Result::Ok then do_job
  #   when Flows::Result::Err then give_up
  #   end
  #
  # @example Matching Results with case and helpers
  #   class Demo
  #     include Flows::Result::Helpers
  #
  #     def simple_usage
  #       case result
  #       when match_ok then do_job
  #       when match_err then give_up
  #       end
  #     end
  #
  #     def with_status_matching
  #       case result
  #       when match_ok(:create) then do_create
  #       when match_ok(:update) then do_update
  #       when match_err(:http_error) then retry
  #       when match_err then give_up
  #       end
  #     end
  #   end
  #
  # @!method ok?
  #   @return [Boolean] `true` if result is successful
  # @!method err?
  #   @return [Boolean] `true` if result is failure
  # @!method unwrap
  #   @return [Object] result data
  #   @raise [AccessError] if called on failure object
  # @!method error
  #   @return [Object] result data
  #   @raise [AccessError] if called on successful object
  #
  # @abstract
  #
  # @since 0.4.0
  class Result
    # @return [Symbol] status of Result Object, default is `:ok` for successful results
    #   and `:err` for failure results.
    attr_reader :status

    # @return [Hash] metadata, don't use it to store business data
    attr_reader :meta

    # Direct creation of this abstract class is forbidden.
    #
    # @raise [StandardError] you will get an error
    def initialize(**)
      raise 'Use Flows::Result::Ok or Flows::Result::Err for build result objects'
    end
  end
end

require_relative 'result/errors'
require_relative 'result/ok'
require_relative 'result/err'
require_relative 'result/helpers'
require_relative 'result/do'
