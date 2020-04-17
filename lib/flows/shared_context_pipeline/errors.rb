module Flows
  class SharedContextPipeline
    # Base error class for {SharedContextPipeline} errors.
    class Error < StandardError; end

    # Raised when initializing {SharedContextPipeline} with no steps.
    class NoStepsError < Error
      def initialize(klass)
        @klass = klass
      end

      def message
        "No steps defined for main track in #{@klass}"
      end
    end
  end
end
