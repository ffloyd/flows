module Flows
  class Shape
    # Class for {Shape} errors.
    class Error < ::Flows::Error
      # @param value [Object] checked value
      # @param msg [String] error message
      def initialize(value, msg)
        @value = value
        @msg = msg
      end

      def message
        [
          'shape check failed for:',
          "  #{@value.inspect}",
          "error: #{@msg}"
        ]
      end
    end
  end
end
