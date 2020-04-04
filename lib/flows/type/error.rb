module Flows
  class Type
    # Class for {Type} errors.
    class Error < ::Flows::Error
      attr_reader :value
      attr_reader :value_error

      # @param value [Object] checked value
      # @param value_error [String] error message
      def initialize(value, value_error)
        @value = value
        @value_error = value_error
      end

      def message
        [
          'type check failed for:',
          "    `#{@value.inspect}`",
          "---\n",
          @value_error
        ].join("\n")
      end
    end
  end
end
