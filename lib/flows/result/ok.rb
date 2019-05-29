module Flows
  class Result
    # Wrapper for successful results
    class Ok < Result
      def initialize(data, status: :success, meta: {})
        super
      end

      def ok?
        true
      end

      def err?
        false
      end

      def unwrap
        @data
      end

      def error
        raise NoErrorError.new(@status, @data)
      end
    end
  end
end
