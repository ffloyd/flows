module Flows
  class Contract
    # Contract for Ruby `Hash` with specified contracts for keys and values.
    #
    # If key contract has transformation - Hash keys will be transformed.
    #
    # If value contract has transformation - Hash values will be transformed.
    #
    # @example
    #     sym_int_hash = Flows::Contract::Hash.new(Symbol, Integer)
    #
    #     sym_int_hash === { a: 1, b: 2 }
    #     # => true
    #
    #     sym_int_hash === { a: 1, b: 'BBB' }
    #     # => true
    class Hash < Contract
      # Stop search for a new type mismatch in keys or values
      # if CHECK_LIMIT errors already found.
      #
      # Applied separately for keys and values.
      CHECK_LIMIT = 10

      HASH_TYPE = CaseEq.new(::Hash)

      # @param key_contract [Contract, Object] contract for keys, non-contract values will be wrapped with {CaseEq}
      # @param value_contract [Contract, Object] contract for values, non-contract values will be wrapped with {CaseEq}
      def initialize(key_contract, value_contract)
        @key_contract = to_contract(key_contract)
        @value_contract = to_contract(value_contract)
      end

      def check!(other)
        HASH_TYPE.check!(other)

        unless other.keys.all?(&@key_contract) && other.values.all?(&@value_contract)
          value_error = report_error(other)
          raise Error.new(other, value_error)
        end

        true
      end

      def transform!(other)
        check!(other)

        other
          .transform_keys { |key| @key_contract.transform!(key) }
          .transform_values { |value| @value_contract.transform!(value) }
      end

      private

      def report_error(other)
        (invalid_key_errors(other) + invalid_value_errors(other)).join("\n")
      end

      def invalid_key_errors(other)
        other.keys.reject(&@key_contract)[0..CHECK_LIMIT].map do |key|
          key_error = @key_contract.check(key).error

          merge_nested_errors("hash key `#{key.inspect}` is invalid:", key_error)
        end
      end

      def invalid_value_errors(other)
        other.values.reject(&@value_contract)[0..CHECK_LIMIT].map do |value|
          value_error = @value_contract.check(value).error

          merge_nested_errors("hash value `#{value.inspect}` is invalid:", value_error)
        end
      end
    end
  end
end
