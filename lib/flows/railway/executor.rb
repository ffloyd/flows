module Flows
  class Railway
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
        patch_last_result(last_result, context)

        last_result
      end

      private

      # :reek:FeatureEnvy is allowed here because meta should be a Hash
      def patch_last_result(last_result, context)
        last_meta = last_result.meta

        last_meta[:railway] = @railway_class_name
        last_meta[:last_step] = context[:last_step]
      end
    end
  end
end
