module Flows
  class Result
    # Result Object for successful results.
    #
    # @see Flows::Result behaviour described here
    class Ok < Result
      def initialize(data, status: :success, meta: {})
        @data = data
        @status = status
        @meta = meta
      end

      def unwrap
        @data
      end

      # @return [true]
      def ok?
        true
      end

      # @return [false]
      def err?
        false
      end

      def error
        raise AccessError, self
      end
    end
  end
end
