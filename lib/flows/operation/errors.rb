module Flows
  module Operation
    # rubocop:disable Style/Documentation
    class NoSuccessShapeError < ::Flows::Error
      def message
        'Missing success output shapes'
      end
    end

    class NoFailureShapeError < ::Flows::Error
      def message
        'Missing failure output shape'
      end
    end

    class NoStepsError < ::Flows::Error
      def message
        'No steps defined'
      end
    end

    class NoStepImplementationError < ::Flows::Error
      def initialize(step_name)
        @step_name = step_name
      end

      def message
        "Missing step implementation for #{@step_name}"
      end
    end

    class MissingOutputError < ::Flows::Error
      def initialize(required_keys, actual_keys)
        @missing_keys = required_keys - actual_keys
      end

      def message
        "Missing keys in output: #{@missing_keys.join(', ')}"
      end
    end
    # rubocop:enable Style/Documentation
  end
end
