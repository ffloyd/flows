module Flows
  module Operation
    # Runner for operation steps
    class Executor
      include ::Flows::Result::Helpers

      def initialize(flow:, success_shapes:, failure_shapes:)
        @flow = flow

        @success_shapes = success_shapes
        @failure_shapes = failure_shapes
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
          shape = @success_shapes[status]
          raise ::Flows::Operation::UnexpectedSuccessStatusError.new(status, @success_shapes.keys) if shape.nil?

          data = extract_data(context[:data], shape)

          ok(status, data)
        when Flows::Result::Failure
          raise ::Flows::Operation::NoFailureShapeError if @failure_shapes.nil?

          shape = @failure_shapes[status]
          raise ::Flows::Operation::UnexpectedFailureStatusError.new(status, @failure_shapes.keys) if shape.nil?

          data = extract_data(context[:data], shape)

          err(status, data)
        end
      end

      def extract_data(output, keys)
        raise ::Flows::Operation::MissingOutputError.new(keys, output.keys) unless keys.all? { |key| output.key?(key) }

        output.slice(*keys)
      end
    end
  end
end
