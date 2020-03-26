module Flows
  class Railway
    # Base class for Railway errors
    class Error < StandardError; end

    # Raised when initializing Railway with no steps
    class NoStepsError < Error
    end
  end
end
