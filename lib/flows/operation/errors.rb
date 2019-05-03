module Flows
  module Operation
    class NoSuccessShapeError < ::Flows::Error; end
    class NoFailureShapeError < ::Flows::Error; end
    class NoStepsError < ::Flows::Error; end
    class NoStepImplementationError < ::Flows::Error; end
    class MissingOutputError < ::Flows::Error; end
  end
end
