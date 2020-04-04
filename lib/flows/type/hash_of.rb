module Flows
  class Type
    # This type describes Ruby `Hash` with specified structure.
    #
    # Hash can have extra keys. Extra keys will be removed after type casting.
    #
    # @example
    #     point_type = Flows::Type::HashOf.new(x: Numeric, y: Numeric)
    #
    #     point_type === { x: 1, y: 2.0 }
    #     # => true
    #
    #     point_type === { x: 1, y: 2.0, name: 'Petr' }
    #     # => true
    #
    #     point_type.cast(x: 1, y: 2.0, name: 'Petr').unwrap
    #     # => { x: 1, y: 2.0 }
    #
    #     point_type.check({ x: 1, name: 'Petr' })
    #     # => Flows::Result::Error.new('missing key `:y`')
    #
    #     point_type.check({ x: 1, y: 'Vasya' })
    #     # => Flows::Result::Error.new('key `:y` has an invalid value: must match `Numeric`')
    class HashOf < Type
      HASH_TYPE = Ruby.new(::Hash)

      def initialize(shape = {})
        @shape = shape.transform_values(&method(:ensure_type))
      end

      def check!(other)
        HASH_TYPE.check!(other)

        errors = check_shape(other)

        raise Error.new(other, errors.join("\n")) if errors.any?

        true
      end

      def cast!(other)
        check!(other)

        other
          .slice(*@shape.keys)
          .map { |key, value| [key, @shape[key].cast!(value)] }
          .to_h
      end

      private

      # :reek:DuplicateMethodCall
      def check_shape(other)
        @shape.each_with_object([]) do |(key, type), errors|
          unless other.key?(key)
            errors << "missing key `#{key.inspect}`"
            next
          end

          result = type.check(other[key])

          errors << merge_nested_errors("key `#{key.inspect}` has an invalid value:", result.error) if result.err?
        end
      end
    end
  end
end
