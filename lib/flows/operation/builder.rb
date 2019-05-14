module Flows
  module Operation
    # Flow builder
    class Builder
      def initialize(steps:, method_source:)
        @method_source = method_source
        @steps = steps
      end

      def call
        resolve_wiring!
        resolve_bodies!

        nodes = build_nodes
        Flows::Flow.new(start_node: nodes.first.name, nodes: nodes)
      end

      private

      def resolve_wiring!
        @steps = @steps.map.with_index do |step, index|
          step.merge(
            next_step: @steps.dig(index + 1, :name) || :term
          )
        end
      end

      def resolve_bodies!
        @steps.map! do |step|
          unless @method_source.respond_to?(step[:name])
            raise ::Flows::Operation::NoStepImplementationError, step[:name]
          end

          step.merge(
            body: @method_source.method(step[:name])
          )
        end
      end

      def build_nodes
        @nodes = @steps.map do |step|
          Flows::Node.new(
            name: step[:name],
            body: step[:body],
            preprocessor: method(:node_preprocessor),
            postprocessor: method(:node_postprocessor),
            router: standard_router(step)
          )
        end
      end

      def node_preprocessor(_input, context, _meta)
        context[:data]
      end

      def node_postprocessor(output, context, _meta)
        output_data = output.success? ? output.unwrap : output.error
        context[:data].merge!(output_data)

        output
      end

      def standard_router(step_definition)
        Flows::Router.new(
          Flows::Result::Success => step_definition[:next_step],
          Flows::Result::Failure => :term
        )
      end
    end
  end
end
