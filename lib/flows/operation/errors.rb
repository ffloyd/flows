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

    class NoStepDefinedError < ::Flows::Error
      def initialize(step_name)
        @step_name = step_name
      end

      def message
        "Missing step or track definition: #{@step_name}"
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

    class UnexpectedSuccessStatusError < ::Flows::Error
      def initialize(actual_status, supported_statuses)
        @actual_status = actual_status.inspect
        @supported_statuses = supported_statuses.map(&:inspect).join(', ')
      end

      def message
        "Unexpeted success result status: `#{@actual_status}`, supported statuses: `#{@supported_statuses}`"
      end
    end

    class UnexpectedFailureStatusError < ::Flows::Error
      def initialize(actual_status, supported_statuses)
        @actual_status = actual_status.inspect
        @supported_statuses = supported_statuses.map(&:inspect).join(', ')
      end

      def message
        "Unexpeted failure result status: `#{@actual_status}`, supported statuses: `#{@supported_statuses}`"
      end
    end
    # rubocop:enable Style/Documentation
  end
end
