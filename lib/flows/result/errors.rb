module Flows
  class Result
    # Base class for Result errors.
    class Error < ::Flows::Error; end

    # Error for invalid data access cases
    class AccessError < Flows::Error
      def initialize(result)
        @result = result
      end

      def message
        [
          base_msg,
          "  Result status: `#{@result.status.inspect}`",
          "  Result data:   `#{data.inspect}`",
          "  Result meta:   `#{@result.meta.inspect}`"
        ].join("\n")
      end

      private

      def base_msg
        case @result
        when Flows::Result::Ok
          'Data in a successful result must be retrieved using `#unwrap` method, not `#error`.'
        when Flows::Result::Err
          'Data in a failure result must be retrieved using `#error` method, not `#unwrap`.'
        end
      end

      def data
        case @result
        when Flows::Result::Ok
          @result.unwrap
        when Flows::Result::Err
          @result.error
        end
      end
    end
  end
end
