module Flows
  class Operation
    # Runner for operation steps
    class Executor
      include ::Flows::Result::Helpers

      def initialize(flow:, ok_shapes:, err_shapes:, class_name:)
        @flow = flow

        @ok_shapes = ok_shapes
        @err_shapes = err_shapes
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
        data = context[:data]

        return ok(status, data) if @ok_shapes == :no_shapes

        shape = @ok_shapes[status]
        raise ::Flows::Operation::UnexpectedSuccessStatusError.new(status, @ok_shapes.keys) if shape.nil?

        data = extract_data(data, shape)

        ok(status, data)
      end

      def build_failure_result(status, context, last_result)
        raise ::Flows::Operation::NoFailureShapeError if @err_shapes.nil?

        meta = build_meta(context, last_result)
        data = context[:data]

        return Flows::Result::Err.new(data, status: status, meta: meta) if @err_shapes == :no_shapes

        shape = @err_shapes[status]
        raise ::Flows::Operation::UnexpectedFailureStatusError.new(status, @err_shapes.keys) if shape.nil?

        data = extract_data(data, shape)

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

        last_meta = last_result.meta
        meta[:nested_metadata] = last_meta if last_meta.any?

        meta
      end
    end
  end
end
