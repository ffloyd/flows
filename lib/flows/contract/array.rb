module Flows
  class Contract
    # Makes a contract for Array from contract for array's element.
    #
    # If underlying contract has transformation -
    # each array element will be transformed.
    #
    # @example
    #     vector = Flows::Contract::Array.new(Numeric)
    #
    #     vector === 10
    #     # => false
    #
    #     vector === [10, 20]
    #     # => true
    class Array < Contract
      # Stop search for a new type mismatch in elements
      # if CHECK_LIMIT errors already found.
      CHECK_LIMIT = 10

      ARRAY_CONTRACT = CaseEq.new(::Array)

      # @param element_contract [Contract, Object] contract for each element. For not-contract values {CaseEq} used.
      def initialize(element_contract)
        @contract = to_contract(element_contract)
      end

      # @see Contract#check!
      def check!(other)
        ARRAY_CONTRACT.check!(other)

        raise Error.new(other, report_errors(other)) unless other.all?(&@contract)

        true
      end

      # @see Contract#transform!
      def transform!(other)
        check!(other)

        other.map { |elem| @contract.transform!(elem) }
      end

      private

      def report_errors(other)
        other.reject(&@contract)[0..CHECK_LIMIT].map do |elem|
          element_error = @contract.check(elem).error

          merge_nested_errors("array element `#{elem.inspect}` is invalid:", element_error)
        end.join("\n")
      end
    end
  end
end
