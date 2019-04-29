module Flows
  class Result
    # Wrapper for successful results
    class Success < Result
      class NoErrorError < Flows::Error; end

      def initialize(data, status: :success, meta: {})
        super
      end

      def success?
        true
      end

      def failure?
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
