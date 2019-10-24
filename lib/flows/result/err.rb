module Flows
  class Result
    # Wrapper for failure results
    class Err < Result
      attr_reader :error

      def initialize(data, status: :failure, meta: {})
        @error = data
        @status = status
        @meta = meta
      end

      def ok?
        false
      end

      def err?
        true
      end

      def unwrap
        raise UnwrapError.new(@status, @error, @meta)
      end
    end
  end
end
