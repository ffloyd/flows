module Flows
  module Railway
    # rubocop:disable Style/Documentation
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
        "Missing step definition: #{@step_name}"
      end
    end
    # rubocop:enable Style/Documentation
  end
end
