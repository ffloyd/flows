module Flows
  class Type
    # This type describes Ruby `Hash` with specified types for keys and values.
    #
    # If type is not a {Flows::Type} it will be automatically wrapped using {Ruby}.
    #
    # @example
    #     po_num = Flows::Type::Predicate 'must be a positive number' do |x|
    #       x.is_a?(Number) && x > 0
    #     end
    #
    #     dict_with_pos_nums = Flows::Type::Hash.new(Symbol, po_num)
    #
    #     dict_with_pos_nums.check({ a: -1 })
    #     # => Flows::Result::Err.new('hash value `-1` is invalid: must be a positive number')
    #
    #     dict_with_pos_nums.check({ 'a' => 1 })
    #     # => Flows::Result::Err.new('hash key `"a"` is invalid: must match `Symbol`')
    #
    #     dict_with_pos_nums === { a: 1, b: 2 }
    #     # => true
    class Hash < Type
      # Stop search for a new type mismatch in keys or values
      # if CHECK_LIMIT errors already found.
      #
      # Applied separately for keys and values.
      CHECK_LIMIT = 10

      HASH_TYPE = Ruby.new(::Hash)

      # @param key_type [Flows::Type, Object] type for all keys
      # @param value_type [Flows::Type, Object] type for all values
      def initialize(key_type, value_type)
        @key_type = ensure_type(key_type)
        @value_type = ensure_type(value_type)
      end

      def check!(other)
        HASH_TYPE.check!(other)

        unless other.keys.all?(&@key_type) && other.values.all?(&@value_type)
          value_error = report_error(other)
          raise Error.new(other, value_error)
        end

        true
      end

      def cast!(other)
        check!(other)
        other
          .transform_keys { |key| @key_type.cast!(key) }
          .transform_values { |value| @value_type.cast!(value) }
      end

      private

      def report_error(other)
        (invalid_key_errors(other) + invalid_value_errors(other)).join("\n")
      end

      def invalid_key_errors(other)
        other.keys.reject(&@key_type)[0..CHECK_LIMIT].map do |key|
          key_error = @key_type.check(key).error

          merge_nested_errors("hash key `#{key.inspect}` is invalid:", key_error)
        end
      end

      def invalid_value_errors(other)
        other.values.reject(&@value_type)[0..CHECK_LIMIT].map do |value|
          value_error = @value_type.check(value).error

          merge_nested_errors("hash value `#{value.inspect}` is invalid:", value_error)
        end
      end
    end
  end
end
