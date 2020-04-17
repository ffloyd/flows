module Flows
  class Railway
    # Base class for Railway errors
    class Error < StandardError; end

    # Raised when initializing Railway with no steps
    class NoStepsError < Error
      def initialize(klass)
        @klass = klass
      end

      def message
        "No steps defined for #{@klass}"
      end
    end
  end
end
