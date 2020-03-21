module Flows
  class Result
    # Result Object for failure results.
    #
    # @see Flows::Result behaviour described here
    class Err < Result
      attr_reader :error

      def initialize(data, status: :err, meta: {})
        @error = data
        @status = status
        @meta = meta
      end

      # @return [false]
      def ok?
        false
      end

      # @return [true]
      def err?
        true
      end

      def unwrap
        raise AccessError, self
      end
    end
  end
end
