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
          next_step = @steps[(index + 1)..-1].find do |candidate|
            candidate[:track_path] == [] ||
              step[:track_path].include?(candidate[:track_path].last)
          end

          step.merge(
            next_step: next_step ? next_step[:name] : :term
          )
        end
      end

      def resolve_bodies!
        @steps.map! do |step|
          step.merge(
            body: step[:custom_body] || resolve_body_from_source(step[:name])
          )
        end
      end

      def resolve_body_from_source(name)
        raise(::Flows::Operation::NoStepImplementationError, name) unless @method_source.respond_to?(name)

        @method_source.method(name)
      end

      def build_nodes
        @nodes = @steps.map do |step|
          Flows::Node.new(
            name: step[:name],
            body: build_final_body(step),
            preprocessor: method(:node_preprocessor),
            postprocessor: method(:node_postprocessor),
            router: make_router(step),
            meta: build_meta(step)
          )
        end
      end

      def build_final_body(step)
        case step[:type]
        when :step
          step[:body]
        when :wrapper
          build_wrapper_body(step[:body], step[:block])
        end
      end

      def build_wrapper_body(wrapper, block)
        suboperation_class = Class.new do
          include ::Flows::Operation
        end

        suboperation_class.instance_exec(&block)
        suboperation_class.no_shape_checks

        suboperation = suboperation_class.new(method_source: @method_source)

        lambda do |**options|
          wrapper.call(**options) { suboperation.call(**options) }
        end
      end

      def build_meta(step)
        {
          type: step[:type],
          name: step[:name],
          track_path: step[:track_path]
        }
      end

      def node_preprocessor(_input, context, _meta)
        context[:data]
      end

      def node_postprocessor(output, context, meta)
        output_data = output.ok? ? output.unwrap : output.error
        context[:data].merge!(output_data)
        context[:last_step] = meta[:name]

        output
      end

      def make_router(step_definition)
        routes = step_definition[:custom_routes]
        check_custom_routes(routes)

        routes[Flows::Result::Ok] ||= step_definition[:next_step]
        routes[Flows::Result::Err] ||= :term

        Flows::Router.new(routes)
      end

      def check_custom_routes(custom_routes)
        custom_routes.values.each do |target|
          next if step_names.include?(target) || target == :term

          raise(::Flows::Operation::NoStepDefinedError, target)
        end
      end

      def step_names
        @step_names ||= @steps.map { |s| s[:name] }
      end
    end
  end
end
