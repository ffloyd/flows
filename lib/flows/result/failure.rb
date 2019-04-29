module Flows
  class Result
    # Wrapper for failure results
    class Failure < Result
      class UnwrapError < Flows::Error; end

      def initialize(data, status: :failure, meta: {})
        super
      end

      def success?
        false
      end

      def failure?
        true
      end

      def unwrap
        raise UnwrapError
      end

      def error
        @data
      end
    end
  end
end
