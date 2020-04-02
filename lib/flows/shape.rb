module Flows
  # A type matchers based on case equality.
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
  # To address this problem we have a simple wrapper {Flows::Shape::Match}.
  #
  # Also lambdas is like predicates with case equality. To wrap lambda check with error message
  # we have {Flows::Shape::Predicate}.
  #
  # {Shape} is an abstract class which requires {#check} method
  # to be implemented. `===` will be automatically implemented
  # when error reporting is not needed.
  #
  # In other words - {Shape} is case equality plus error message.
  #
  # In case when one shape checks several things ({Flows::Shape::Hash} for example)
  # error message must contain all the violations, not only the first one.
  #
  # @abstract
  #
  # @!method do_check( other )
  #   @abstract
  #   Implement this as a private method.
  #   @return [true] `true` if check succesful
  #   @return [String] error message if check failed
  class Shape
    include Flows::Result::Helpers

    # Case equality check.
    #
    # Based on {#check} method.
    #
    # @return [Boolean] check result
    def ===(other)
      do_check(other) == true
    end

    # Checks `other` for shape match.
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

    # Offensive check variant.
    #
    # @return [true]
    # @raise [Flows::Shape::Error] if check failed
    def check!(other)
      check_result = do_check(other)

      raise Error.new(other, check_result) if check_result.is_a?(String)

      true
    end

    # For some values you can extract correct value from possibly incorrect one.
    #
    # For example, to omit unexpected keys in Hash.
    #
    # In default implementation extract does not modify value.
    #
    # If shape has internal shapes - all internal shapes must be called via extract.
    #
    # @return [Flows::Result::Ok<Object>] successful result with extracted data
    # @return [Flows::Result::Err<String>] failure result with error message
    def extract(other)
      raw_result = do_check(other)

      case raw_result
      when true then ok_data(other)
      when String then err_data(raw_result)
      end
    end
  end
end

require_relative 'shape/error'
require_relative 'shape/match'
require_relative 'shape/predicate'

require_relative 'shape/helpers'
