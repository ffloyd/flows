module Flows
  class Result
    # Wrapper for failure results
    class Err < Result
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
        raise UnwrapError.new(@status, @data, @meta)
      end

      def error
        @data
      end
    end
  end
end
