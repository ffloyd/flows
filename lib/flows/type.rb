module Flows
  # @abstract
  #
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
  # {Type} is an abstract class which requires {#check!}  method
  # to be implemented. It provides {#===}, {#check}, {#cast} and {#cast!} methods for usage in
  # different scenarios.
  #
  # {#cast!} must be overriden for types with defined casting behaviour.
  # _If a type cast is successful it must pass a type check._ It means that it's a bad
  # idea to allow casts from numbers to strings. But cast a hash with extra fields to
  # a hash with only needed fields - is a good example of casting in `Flows::Type`.
  #
  # In other words - {Type} is Ruby's case equality plus error message plus safe type casting.
  #
  # In case when one type checks several things ({Flows::Type::HashOf} for example)
  # error message must contain all the violations, not only the first one.
  #
  # ## Private methods
  #
  # Some private methods are defined to simplify type implementations:
  #
  # `ensure_type(value) => Flows::Type` - if value is a Flows Type does nothing.
  # Otherwise wraps value with {Ruby}. Useful in initializers.
  #
  # `merge_nested_errors(description, nested_error) => String` - to make an accurate
  # multiline error messages with indentation.
  #
  # @!method check!( other )
  #   @abstract
  #   Checks for type match.
  #   @return [true] `true` if check succesful
  #   @raise [Flows::Type::Error] if check failed
  class Type
    include Flows::Result::Helpers

    # Case equality check.
    #
    # @return [Boolean] check result
    def ===(other)
      check!(other)
      true
    rescue Flows::Type::Error
      false
    end

    # Checks `other` for type match.
    #
    # @param other [Object] object to check
    # @return [Flows::Result::Ok<true>] if check successful
    # @return [Flows::Result::Err<String>] if check failed
    def check(other)
      check!(other)
      ok_data(true)
    rescue ::Flows::Type::Error => err
      err_data(err.value_error)
    end

    # For some values you can cast correct value from possibly incorrect one.
    #
    # For example, to omit unexpected keys in Hash.
    #
    # Override this method to implement type cast behaviour.
    #
    # If type is built from other types - all internal types must be called via {#cast}.
    #
    # @return [Object] successful result with value after type cast
    # @raise [Flows::Type::Error] if check failed
    def cast!(other)
      check!(other)
      other
    end

    # For some values you can cast correct value from possibly incorrect one.
    #
    # For example, to omit unexpected keys in Hash.
    #
    # If type is built from other types - all internal types must be called via {#cast}.
    #
    # @return [Flows::Result::Ok<Object>] successful result with value after type cast
    # @return [Flows::Result::Err<String>] failure result with error message
    def cast(other)
      ok_data(cast!(other))
    rescue ::Flows::Type::Error => err
      err_data(err.value_error)
    end

    # Allows to use types for filtration.
    #
    # @example
    #     pos_num = Flows::Type::Predicate.new 'must be positive' do |x|
    #       x > 0
    #     end
    #
    #     [1, 2, 3].all?(&pos_num)
    #     # => true
    def to_proc
      proc do |obj|
        self === obj # rubocop:disable Style/CaseEquality
      end
    end

    private

    # :reek:UtilityFunction
    def ensure_type(value)
      value.is_a?(::Flows::Type) ? value : Ruby.new(value)
    end

    # :reek:UtilityFunction
    def merge_nested_errors(description, nested_errors)
      shifted = nested_errors.split("\n").map { |str| '    ' + str }.join("\n")

      description + "\n" + shifted
    end
  end
end

require_relative 'type/error'
require_relative 'type/ruby'
require_relative 'type/predicate'
require_relative 'type/hash'
require_relative 'type/hash_of'

require_relative 'type/helpers'
