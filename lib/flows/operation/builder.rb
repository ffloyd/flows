require_relative './builder/build_router'

module Flows
  class Operation
    # Flow builder
    class Builder
      attr_reader :steps, :method_source, :deps

      def initialize(steps:, method_source:, deps:)
        @method_source = method_source
        @steps = steps
        @deps = deps

        @step_names = @steps.map { |step| step[:name] }
      end

      def call
        resolve_wiring
        resolve_bodies

        nodes = build_nodes
        Flows::Flow.new(start_node: nodes.first.name, nodes: nodes)
      end

      private

      def resolve_wiring # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        # we have to disable some linters for performance reasons
        # this method can be simplified using `map.with_index`, but while loops is about
        # 2x faster for such cases.
        index = 0
        steps_count = @steps.length

        while index < steps_count
          current_step = @steps[index]
          next_step_name = nil

          inner_index = index + 1
          while inner_index < steps_count
            candidate = @steps[inner_index]
            track_path = candidate[:track_path]
            candidate_last_track = track_path.last

            if track_path == [] || current_step[:track_path].include?(candidate_last_track)
              next_step_name = candidate[:name]
              break
            end

            inner_index += 1
          end

          current_step[:next_step] = next_step_name || :term

          index += 1
        end
      end

      def resolve_bodies
        @steps.each do |step|
          step.merge!(
            body: step[:custom_body] || resolve_body_from_source(step[:name])
          )
        end
      end

      # We allow here :reek:ManualDispatch because it's the only way to go here
      def resolve_body_from_source(name)
        return @deps[name] if @deps.key?(name)

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
            router: BuildRouter.call(step[:custom_routes], step[:next_step], @step_names),
            meta: build_meta(step)
          )
        end
      end

      def build_final_body(step)
        body = step[:body]

        case step[:type]
        when :step
          body
        when :wrapper
          build_wrapper_body(body, step[:block])
        end
      end

      def build_wrapper_body(wrapper, block)
        # TODO: this may be dangerous when end user will create something like ApplicationOperation
        suboperation_class = Class.new(::Flows::Operation)

        suboperation_class.instance_exec(&block)
        suboperation_class.no_shape

        suboperation = suboperation_class.new(method_source: @method_source, deps: @deps)

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
    end
  end
end
