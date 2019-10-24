module Flows
  class Result
    # Wrapper for successful results
    class Ok < Result
      attr_reader :unwrap

      def initialize(data, status: :success, meta: {})
        @unwrap = data
        @status = status
        @meta = meta
      end

      def ok?
        true
      end

      def err?
        false
      end

      def error
        raise NoErrorError.new(@status, @unwrap)
      end
    end
  end
end
