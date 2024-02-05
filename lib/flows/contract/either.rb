module Flows
  class Contract
    # Allows to combine two or more contracts with "or" logic.
    #
    # First matching contract from provided list will be used.
    #
    # @example
    #     str_or_sym = Flows::Contract::Either.new(String, Symbol)
    #
    #     str_or_sym === 'AAA'
    #     # => true
    #
    #     str_or_sym === :AAA
    #     # => true
    #
    #     str_or_sym === 111
    #     # => false
    class Either < Contract
      # @param contracts [Array<Contract, Object>] contract list. Non-contract elements will be wrapped with {CaseEq}.
      def initialize(*contracts)
        raise 'Contract list must not be empty' if contracts.empty?

        @contracts = contracts.map { |c| to_contract(c) }
      end

      # @see Contract#check!
      def check!(other)
        errors = @contracts.each_with_object([]) do |con, errs|
          result = con.check(other)

          return true if result.ok?

          errs << result.error
        end

        raise Error.new(other, errors.join("\nOR "))
      end

      # @see Contract#transform!
      def transform!(other)
        errors = @contracts.each_with_object([]) do |con, errs|
          result = con.transform(other)

          return result.unwrap if result.ok?

          errs << result.error
        end

        raise Error.new(other, errors.join("\nOR "))
      end
    end
  end
end
