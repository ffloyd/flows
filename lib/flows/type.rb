module Flows
  # A type matchers based on Ruby's case equality.
  #
  # Ruby lacks a good type checking system, even runtime one.
  # So, this abstract class defines a family of advanced checkers
  # for type-checking your data.
  #
  # The general idea is to rely on Ruby's
  # [case equality](https://blog.arkency.com/the-equals-equals-equals-case-equality-operator-in-ruby/) (`===`).
  #
  # As you may see - case equality is already a type check. We don't need additional checkers to test
  # if something is a `String` because `String === x` will do the job.
  # The problem is that `===` does not provide any error messages.
  #
  # To address this problem we have a simple wrapper {Flows::Type::Ruby}.
  #
  # Also lambdas is like predicates with case equality. To wrap lambda check with error message
  # we have {Flows::Type::Predicate}.
  #
  # {Type} is an abstract class which requires {#do_check} private method
  # to be implemented. It provides {#===}, {#check} and {#cast} methods for usage in
  # different scenarios.
  #
  # {#cast} must be overriden for types with defined casting behaviour.
  # _If a type cast is successful it must pass a type check._ It means that it's a bad
  # idea to allow casts from numbers to strings. But cast a hash with extra fields to
  # a hash with only needed fields - is a good example of casting in `Flows::Type`.
  #
  # In other words - {Type} is Ruby's case equality plus error message plus safe type casting.
  #
  # In case when one type checks several things ({Flows::Type::HashOf} for example)
  # error message must contain all the violations, not only the first one.
  #
  # @abstract
  #
  # @!method do_check( other )
  #   @abstract
  #   Implement this as a private method.
  #   @return [true] `true` if check succesful
  #   @return [String] error message if check failed
  class Type
    include Flows::Result::Helpers

    # Case equality check.
    #
    # @return [Boolean] check result
    def ===(other)
      do_check(other) == true
    end

    # Checks `other` for type match.
    #
    # @param other [Object] object to check
    # @return [Flows::Result::Ok<true>] if check successful
    # @return [Flows::Result::Err<String>] if check failed
    def check(other)
      raw_result = do_check(other)

      case raw_result
      when true then ok_data(true)
      when String then err_data(raw_result)
      end
    end

    # Offensive type check.
    #
    # @return [true]
    # @raise [Flows::Type::Error] if check failed
    def check!(other)
      check_result = do_check(other)

      raise Error.new(other, check_result) if check_result.is_a?(String)

      true
    end

    # For some values you can cast correct value from possibly incorrect one.
    #
    # For example, to omit unexpected keys in Hash.
    #
    # In default implementation cast does not modify a value.
    # Override this method for types with casting logic.
    #
    # If type is built from other types - all internal types must be called via {#cast}.
    #
    # @return [Flows::Result::Ok<Object>] successful result with value after type cast
    # @return [Flows::Result::Err<String>] failure result with error message
    def cast(other)
      raw_result = do_check(other)

      case raw_result
      when true then ok_data(other)
      when String then err_data(raw_result)
      end
    end
  end
end

require_relative 'type/error'
require_relative 'type/ruby'
require_relative 'type/predicate'

require_relative 'type/helpers'
