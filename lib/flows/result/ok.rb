module Flows
  class Result
    # Result Object for successful results.
    #
    # @see Flows::Result behaviour described here
    class Ok < Result
      attr_reader :unwrap

      def initialize(data, status: :success, meta: {})
        @unwrap = data
        @status = status
        @meta = meta
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
