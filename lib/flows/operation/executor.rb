module Flows
  module Operation
    # Runner for operation steps
    class Executor
      include ::Flows::Result::Helpers

      def initialize(flow:, success_shapes:, failure_shapes:, class_name:)
        @flow = flow

        @success_shapes = success_shapes
        @failure_shapes = failure_shapes
        @operation_class_name = class_name
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
        when Flows::Result::Ok then build_success_result(status, context)
        when Flows::Result::Err then build_failure_result(status, context, last_result)
        end
      end

      def build_success_result(status, context)
        shape = @success_shapes[status]
        raise ::Flows::Operation::UnexpectedSuccessStatusError.new(status, @success_shapes.keys) if shape.nil?

        data = extract_data(context[:data], shape)

        ok(status, data)
      end

      def build_failure_result(status, context, last_result)
        raise ::Flows::Operation::NoFailureShapeError if @failure_shapes.nil?

        shape = @failure_shapes[status]
        raise ::Flows::Operation::UnexpectedFailureStatusError.new(status, @failure_shapes.keys) if shape.nil?

        data = extract_data(context[:data], shape)
        meta = build_meta(context, last_result)

        Flows::Result::Err.new(data, status: status, meta: meta)
      end

      def extract_data(output, keys)
        raise ::Flows::Operation::MissingOutputError.new(keys, output.keys) unless keys.all? { |key| output.key?(key) }

        output.slice(*keys)
      end

      def build_meta(context, last_result)
        meta = {
          operation: @operation_class_name,
          step: context[:last_step],
          context_data: context[:data]
        }

        meta[:nested_metadata] = last_result.meta if last_result.meta.any?

        meta
      end
    end
  end
end
