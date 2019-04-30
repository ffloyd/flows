module Flows
  module Operation
    # Runner for operation steps
    class Executor
      include ::Flows::Result::Helpers

      def initialize(operation, flow)
        @operation = operation
        @flow = flow

        @success_filter = operation.class.success_filter
        @failure_filter = operation.class.failure_filter
      end

      def call(**params)
        context = { data: params }
        last_result = @flow.call(nil, context: context)

        build_result(last_result, context)
      end

      private

      def build_result(last_result, context)
        status = last_result.status

        case last_result
        when Flows::Result::Success
          data = context[:data].slice(*@success_filter[status])

          ok(status, data)
        when Flows::Result::Failure
          data = context[:data].slice(*@failure_filter[status])

          err(status, data)
        end
      end
    end
  end
end
