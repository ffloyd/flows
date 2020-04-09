require_relative 'contract/error'

require_relative 'contract/case_eq'
require_relative 'contract/predicate'

require_relative 'contract/transformer'
require_relative 'contract/compose'
require_relative 'contract/either'

require_relative 'contract/hash'
require_relative 'contract/hash_of'
require_relative 'contract/array'
require_relative 'contract/tuple'

require_relative 'contract/helpers'

module Flows
  # @abstract
  #
  # A type contract based on Ruby's case equality.
  #
  # ## Motivation
  #
  # In ruby we have limited ability to express type contracts.
  # Because of the dynamic nature of the language we cannot provide type specs or signatures for methods.
  # We can provide type specs in a form of YARD documentation, but in this way we have no real type checking.
  # Nothing will stop execution if type contract is violated.
  #
  # Flows Contracts are designed to provide runtime type checks for critical places in your code.
  # Let's review options we have except Flows Contracts and then define what is Flows Contract more strictly.
  #
  # Recently in the Ruby community, static/runtime type checking tools started to evolve.
  # The most advanced solution right now is [Sorbet](https://sorbet.org/).
  # But Sorbet solves a different problem: it provides static type checking for the whole codebase.
  # Each method will be checked. Moreover, Sorbet is a tool like bundler or rake,
  # not just a library.
  #
  # In contrast, Flows Contracts are designed to be used in critical places only.
  # For example to declare input and output contracts for your service objects.
  # Or to express contracts between application layers
  # (between Data Access Layer and Business Logic Layer for example).
  #
  # As an optional feature Sorbet provides [runtime checks](https://sorbet.org/docs/runtime).
  # And if you already using Sorbet you may use it to express type contracts also.
  # The main differences between Sorbet Runtime and Flows Contracts are:
  #
  # * Contracts relies on Ruby's case equality and set of helper Contract classes for the most common cases.
  #   Sorbet provides it's own type system and you have to learn it.
  # * It may be overkill to use Sorbet for expressing contracts only.
  #   In contrast, Flows Contracts are not designed to provide contract for each method in your codebase.
  # * Sorbet Runtime checks should be a bit faster then Contracts checks (because of transformations).
  # * The main advantage of Flows Contracts is _transformations_.
  #   It allows you to slightly transform data using Contract
  #   which adds some degree of flexibility to your entities.
  #   See Tranformations section of this documentation for details.
  #
  # Let's check what we have for runtime type checking in pure Ruby.
  # To make some runtime type checks we have at least two ways:
  #
  # * methods like `#is_a?`, `#kind_of?` and `#class` can check if subject is an instance of a particular class
  # * case equality (`===`) in combination with `case` can check different things depends on concrete class.
  #   Check [this article](https://blog.arkency.com/the-equals-equals-equals-case-equality-operator-in-ruby/)
  #   for details.
  #
  # As you may see - case equality is already a contract check. We don't need additional checkers to test
  # if something is a `String` because `String === x` will do the job.
  # Also lambdas is like predicates with case equality.
  # Ranges check if subject in a range and regular expressions check for string match.
  # The problem is that `===` does not provide any error messages.
  # Second problem - `===` is not an object - it's just a method.
  # Contract should be an object, it opens more ways of composition.
  #
  # _So, Flows Contract is a case equality check wrapped into Contract class instance
  # with assigned error message and optional transformation logic._
  #
  # ## Implementation
  #
  # {Contract} is an abstract class which requires {#check!} method
  # to be implemented. It provides {#===}, {#check}, {#to_proc}, {#transform} and {#transform!} methods for usage in
  # different scenarios. More details in the methods' documentation.
  #
  # {#transform!} must be overriden for types with defined transforming behaviour.
  # By default no transformation defined - input will be equal to output.
  # See Transformations and Transformation Laws sections of this documentation for details.
  #
  # ## Transformations
  #
  # Contract can be used in two ways:
  #
  # * to check if data matches a contract ({#check}, {#check!}, {#===}, {#to_proc})
  # * to check & slightly transform data ({#transform}, {#transform!})
  #
  # Transformation is a way to slightly adjust input value before usage.
  # Good example is when your method accepts both String and Symbol as a name for something,
  # but internally name should always be a Symbol.
  # So, contract for this case can be expressed in the following way:
  #
  # > Accept either String or Symbol, convert valid value to Symbol
  #
  # In this way we still can use both String and Symbol instances as argument,
  # but in the method's implementation we can be sure that we always get Symbol.
  #
  # In the situation when you have to transform one or two arguments
  # it's easier to merely rely on Ruby's methods like `#to_sym`, `#to_s`, etc.
  # But in the cases when we talking about 3-6 arguments or nested arguments -
  # contracts will be more convenient way to express transformations.
  #
  # ## Transformation Laws
  #
  # When you writing transformations for your contract you MUST implement it
  # with respect to the following laws:
  #
  #     # let `c` be an any contract
  #     # let `x` be an any value valid for `c`
  #     # the following statements MUST be true
  #
  #     # 1. transformed value MUST match the contract:
  #     c.check!(c.transform!(x)) == true
  #
  #     # 2. tranformation of transformed value MUST has no effect:
  #     c.transform(x) == c.transform(c.transform(x))
  #
  # If you violate these laws - you'll get undefined behaviour of contracts.
  #
  # The meaning of these laws can be explained through [Equivalence Relation](https://en.wikipedia.org/wiki/Equivalence_relation).
  # Let's use the following contract as example:
  #
  # > Accepts natural numbers except zero in form of String or Integer, transforms to Integer
  #
  # We can define a type using a set of all possible type values. For our contract such set can be
  # described like `[1, '1', 2, '2', ...]`.
  #
  # First law says that transformation result must not leave a type.
  # In other words: transformation is a function from contract type to contract type.
  #
  # Second law does two things:
  #
  # * split values of type into [equivalence classes](https://en.wikipedia.org/wiki/Equivalence_class)
  # * for each equivalence class defines one and only one value which should be a transform result for
  #   any value inside the equivalent class. You may call it a tranformation [fixpoint](https://en.wikipedia.org/wiki/Fixed_point_(mathematics)).
  #
  # In our example partition will look like this: `[[1, '1'], [2, '2'], ...]`.
  # Each equivalence class consists of Integer and String form of the same natural number.
  # And Integer form is a fixpoint.
  #
  # Let's review another example:
  #
  # > Accepts String, transform is `String#strip`
  #
  # In this example each equivalent class is a set of stripped string and all the possible non-stripped variations.
  # Fixpoint is a stripped string.
  #
  # You may think about transformations as transformers (form cinema and animation).
  # When transformer transforms - it's still the same guy, but in different form (first law).
  # And fixpoint is transformer main form. We remember Megatron mostly as robot, not as truck. (second law)
  #
  # If you find contract transformation too complex abstraction - you can merely not use it.
  # Flows Contracts without transforms become just type contracts.
  #
  # **You MUST be extra careful with transformations and {Compose}.
  # You cannot just compose any set of types and get a correct result.
  # See {Compose} documentation for details**
  #
  # ## Low-level contracts
  #
  # Flows provides some low-level contract classes.
  # In almost all the cases you don't need to implement your own Contract class
  # and you only need to compose your contract from this helper classes.
  #
  # Wrappers for Ruby objects:
  #
  # * {CaseEq} - to wrap Ruby's case equality with error message.
  #   Automatically applied if you pass some Ruby object instead of
  #   {Contract} to some contract initializer.
  #   Please preserve such behaviour in custom contracts.
  # * {Predicate} - to wrap lambda-check with error message
  #
  # Composition and modification of contracts:
  #
  # * {Transformer} - to wrap existing contract with some transformation
  # * {Compose} - to merge two or more contracts
  # * {Either} - to make "or"-contract from two or more provided contracts. (String or Symbol, for example)
  #
  # Contracts for common Ruby collection types:
  #
  # * {Hash} - restrict keys by some contract and values by another contract
  # * {HashOf} - restrict values under particular keys by particular contracts
  # * {Array} - restrict array elements with some contract
  # * {Tuple} - restrict fixed-size array elements with contracts
  #
  # Using these classes as is can be too verbose and ugly when building complex contracts.
  # To address this issue Contract class has singleton methods as shortcuts and {.make} class method as DSL:
  #
  #     # Accepts any string, transforms into stripped variant
  #     strip_str = Flows::Contract.transformer(String, &:strip)
  #
  #     strip_str === 111
  #     # => false
  #
  #     strip_str.transform!('  AAA  ')
  #     # => 'AAA'
  #
  #     # Accepts positive integers
  #     pos_int = Flows::Contract.compose(
  #       Integer,
  #       Flows::Contract.predicate('must be positive', &:positive?)
  #     )
  #
  #     pos_int === 10
  #     # => true
  #
  #     pos_int === -10
  #     # => false
  #
  #     # Accepts numbers in String format
  #     str_num = Flows::Contract.make do
  #       compose(
  #         String,
  #         case_eq(/\A\d+\z/, 'must be a number')
  #       )
  #     end
  #
  #     # Accepts integer or number as string, transforms to integer
  #     pos_int_from_str = transformer(either(Integer, str_num), &:to_i)
  #
  #     pos_int_from_str === 10
  #     # => true
  #
  #     pos_int_from_str === '-10'
  #     # => false
  #
  #     pos_int_from_str.transform!('10')
  #     # => 10
  #
  #     pos_int_from_str.transform!(10)
  #     # => 10
  #
  #     # Example of a complex contract
  #     user_contract = Flows::Contract.make do
  #       hash_of(
  #         name: strip_str,
  #         email: strip_str,
  #         password_hash: String,
  #         age: pos_int_from_str,
  #         addresses: array(hash_of(
  #           country: strip_str,
  #           street: strip_str
  #         ))
  #       )
  #     end
  #
  #     result = user_contract.transform!(
  #       name: '  Roman ',
  #       email: 'bla@blabla.com',
  #       password_hash: '01234567890ABCDEF',
  #       age: '10',
  #       addresses: [],
  #       blabla: 'blablabla' # extra field will be removed by HashOf#transform
  #     )
  #
  #     result == {
  #       name: 'Roman',
  #       email: 'bla@blabla.com',
  #       password_hash: '01234567890ABCDEF',
  #       age: 10,
  #       addresses: []
  #     }
  #
  # All the shortcuts (without {.make}) are available as a separate module: {Helpers}.
  #
  # It's up to lead developer how to integrate contracts into app.
  # You may put contract into constant and use it in the first line of your method.
  # Or you can write some DSL.
  # But you should avoid constructing static contracts at runtime -
  # it's better to instantiate them during loading time (by putting it into constant, for example).
  #
  # TODO: Some {SharedContextPipeline} plugins will add DSL for contracts.
  # So, you don't need to invent anything to use contracts with shared context pipelines.
  #
  # ## Private helper methods
  #
  # Some private utility methods are defined to simplify new contract implementations:
  #
  # `to_contract(value) => Flows::Contract` - if value is a Contract does nothing.
  # Otherwise wraps value with {CaseEq}. Useful in initializers.
  #
  # `merge_nested_errors(description, nested_error) => String` - to make an accurate
  # multiline error messages with indentation.
  #
  # @!method check!( other )
  #   @abstract
  #   Checks for type match.
  #   @return [true] `true` if check succesful
  #   @raise [Flows::Contract::Error] if check failed
  class Contract
    # Case equality check.
    #
    # Based on {#check!}
    #
    # @example Contracts and Ruby's case
    #
    #     case value
    #     when contract1 then blablabla
    #     when contract2 then blablabla2
    #     end
    #
    # @return [Boolean] check result
    def ===(other)
      check!(other)
      true
    rescue Flows::Contract::Error
      false
    end

    # Checks `other` for type match.
    #
    # Based on {#check!}.
    #
    # @param other [Object] object to check
    # @return [Flows::Result::Ok<true>] if check successful
    # @return [Flows::Result::Err<String>] if check failed
    def check(other)
      check!(other)
      Result::Ok.new(true)
    rescue ::Flows::Contract::Error => err
      Result::Err.new(err.value_error)
    end

    # Check and transform value.
    #
    # Override this method to implement type transform behaviour.
    #
    # If contract is built from other contracts -
    # all internal contracts must be called via {#transform}.
    #
    # You must obey Transformation Laws (see {Contract} class documentation).
    #
    # @return [Object] successful result with value after transformation
    # @raise [Flows::Contract::Error] if check failed
    def transform!(other)
      check!(other)
      other
    end

    # Check and transform value.
    #
    # Based on {#transform!}.
    #
    # @return [Flows::Result::Ok<Object>] successful result with value after type transform
    # @return [Flows::Result::Err<String>] failure result with error message
    def transform(other)
      Result::Ok.new(transform!(other))
    rescue ::Flows::Contract::Error => err
      Result::Err.new(err.value_error)
    end

    # Allows to use contract as proc.
    #
    # Based on {#===}.
    #
    # @example Check all elements in an array
    #     pos_num = Flows::Contract::Predicate.new 'must be positive' do |x|
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

    class << self
      include Helpers

      # @example
      #     Flows::Contract.make { transformer(either(Symbol, String), &:to_sym) }
      def make(&block)
        instance_exec(&block)
      end
    end

    private

    # :reek:UtilityFunction
    def to_contract(value)
      value.is_a?(::Flows::Contract) ? value : CaseEq.new(value)
    end

    # :reek:UtilityFunction
    def merge_nested_errors(description, nested_errors)
      shifted = nested_errors.split("\n").map { |str| '    ' + str }.join("\n")

      description + "\n" + shifted
    end
  end
end
