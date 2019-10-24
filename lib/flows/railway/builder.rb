module Flows
  class Railway
    # Flow builder
    class Builder
      attr_reader :steps, :method_source, :deps

      def initialize(steps:, method_source:, deps:)
        @method_source = method_source
        @steps = steps
        @deps = deps
      end

      def call
        nodes = build_nodes
        Flows::Flow.new(start_node: nodes.first.name, nodes: nodes)
      end

      private

      def build_nodes
        @steps
          .to_a(body_resolver: method(:resolve_step_body))
          .map(&:to_node)
      end

      # :reek:ManualDispatch - is the only way to go
      def resolve_step_body(name)
        return @deps[name] if @deps.key?(name)

        raise(::Flows::Railway::NoStepImplementationError, name) unless @method_source.respond_to?(name)

        @method_source.method(name)
      end
    end
  end
end
