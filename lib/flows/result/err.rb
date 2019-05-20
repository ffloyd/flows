module Flows
  class Result
    # Wrapper for failure results
    class Err < Result
      class UnwrapError < Flows::Error; end

      def initialize(data, status: :failure, meta: {})
        super
      end

      def ok?
        false
      end

      def err?
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
