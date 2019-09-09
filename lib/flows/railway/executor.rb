module Flows
  module Railway
    # Runner for railway steps
    class Executor
      include ::Flows::Result::Helpers

      def initialize(flow:, class_name:)
        @flow = flow
        @railway_class_name = class_name
      end

      def call(**params)
        context = {}
        last_result = @flow.call(ok(params), context: context)

        last_result.meta[:railway] = @railway_class_name
        last_result.meta[:last_step] = context[:last_step]

        last_result
      end
    end
  end
end
