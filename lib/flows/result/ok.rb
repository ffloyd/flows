module Flows
  class Result
    # Wrapper for successful results
    class Ok < Result
      class NoErrorError < Flows::Error; end

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
        raise NoErrorError
      end
    end
  end
end
