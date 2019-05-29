module Flows
  class Result
    # Error for unwrapping non-successful result object
    class UnwrapError < Flows::Error
      def initialize(status, data)
        @status = status
        @data = data
      end

      def message
        "You're trying to unwrap non-successful result with status `#{@status.inspect}` and data `#{@data.inspect}`"
      end
    end

    # Error for dealing with failure result as success one
    class NoErrorError < Flows::Error
      def initialize(status, data)
        @status = status
        @data = data
      end

      def message
        "You're trying to get error data for successful result with status \
`#{@status.inspect}` and data `#{@data.inspect}`"
      end
    end
  end
end
