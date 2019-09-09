module Flows
  module Railway
    # Flow builder
    class Builder
      attr_reader :steps, :method_source, :deps

      def initialize(steps:, method_source:, deps:)
        @method_source = method_source
        @steps = steps
        @deps = deps
      end

      def call
        resolve_bodies_and_wiring!

        nodes = build_nodes
        Flows::Flow.new(start_node: nodes.first.name, nodes: nodes)
      end

      private

      def resolve_bodies_and_wiring!
        index = 0

        while index < @steps.length
          current_step = @steps[index]

          current_step[:next_step] = @steps[index + 1]&.fetch(:name) || :term
          current_step[:body] = current_step[:custom_body] || resolve_body_from_source(current_step[:name])

          index += 1
        end
      end

      def resolve_body_from_source(name)
        return @deps[name] if @deps.key?(name)

        raise(::Flows::Railway::NoStepImplementationError, name) unless @method_source.respond_to?(name)

        @method_source.method(name)
      end

      def build_nodes
        @nodes = @steps.map do |step|
          Flows::Node.new(
            name: step[:name],
            body: step[:body],
            preprocessor: method(:node_preprocessor),
            postprocessor: method(:node_postprocessor),
            router: Flows::ResultRouter.new(step[:next_step], :term),

            meta: { name: step[:name] }
          )
        end
      end

      def node_preprocessor(input, _context, _meta)
        input.unwrap
      end

      def node_postprocessor(output, context, meta)
        context[:last_step] = meta[:name]

        output
      end
    end
  end
end
