module Flows
  class SharedContextPipeline
    # Base error class for {SharedContextPipeline} errors.
    class Error < StandardError; end

    # Raised when initializing {SharedContextPipeline} with no steps.
    class NoStepsError < Error; end
  end
end
