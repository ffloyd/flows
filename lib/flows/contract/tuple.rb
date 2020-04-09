module Flows
  class Contract
    # Makes a contract fixed size array.
    #
    # Underlying contracts' transformations are applied.
    #
    # @example
    #     name_age = Flows::Contract::Tuple.new(String, Integer)
    #
    #     name_age === ['Roman', 29]
    #     # => true
    #
    #     name_age === [10, 20]
    #     # => false
    class Tuple < Contract
      ARRAY_CONTRACT = CaseEq.new(::Array)

      # @param contracts [Array<Contract, Object>] contract list. {CaseEq} applied to non-contract values.
      def initialize(*contracts)
        @contracts = contracts.map(&method(:to_contract))
      end

      # @see Contract#check!
      def check!(other)
        ARRAY_CONTRACT.check!(other)
        check_length(other)

        errors = collect_errors(other)
        return true if errors.empty?

        raise Error.new(other, render_errors(other, errors))
      end

      # @see Contract#transform!
      def transform!(other)
        check!(other)

        other.map.with_index do |elem, index|
          @contracts[index].transform!(elem)
        end
      end

      private

      def check_length(other)
        return if other.length == @contracts.length

        raise Error.new(other, "array length mismatch: must be #{@contracts.length}, got #{other.length}")
      end

      def collect_errors(other)
        other.each_with_object({}).with_index do |(elem, errors), index|
          result = @contracts[index].check(elem)

          errors[index] = result.error if result.err?
        end
      end

      def render_errors(other, errors)
        errors.map do |index, err|
          elem = other[index]
          merge_nested_errors(
            "array element `#{elem.inspect}` with index #{index} is invalid:",
            err
          )
        end.join("\n")
      end
    end
  end
end
