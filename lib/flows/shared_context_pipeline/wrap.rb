module Flows
  class SharedContextPipeline
    # @api private
    class Wrap
      attr_reader :router_def
      attr_reader :tracks_definitions

      # :reek:Attribute
      attr_accessor :next_step

      EMPTY_HASH = {}.freeze

      NODE_PREPROCESSOR = lambda do |_input, context, _node_meta|
        [[context], EMPTY_HASH]
      end

      NODE_POSTPROCESSOR = lambda do |result, context, _node_meta|
        context[:data].merge!(result.instance_variable_get(:@data))

        result
      end

      def initialize(method_name:, router_def:, &tracks_definitions)
        @method_name = method_name
        @router_def = router_def
        @tracks_definitions = tracks_definitions

        singleton_class.extend DSL::Tracks
        singleton_class.extend Result::Helpers

        singleton_class.instance_exec(&tracks_definitions)
      end

      # on `#dup` we're getting new empty singleton class
      # so we need to initialize it like original one
      def initialize_dup(other)
        singleton_class.extend DSL::Tracks
        singleton_class.extend Result::Helpers
        singleton_class.instance_exec(&other.tracks_definitions)
      end

      def name
        singleton_class.tracks.first_step_name
      end

      def to_node(method_source)
        Flows::Flow::Node.new(
          body: make_body(method_source),
          router: router_def.to_router(next_step),
          meta: { wrap_name: @method_name },
          preprocessor: NODE_PREPROCESSOR,
          postprocessor: NODE_POSTPROCESSOR
        )
      end

      private

      def make_flow(method_source)
        singleton_class.tracks.to_flow(method_source)
      end

      def make_body(method_source)
        flow = make_flow(method_source)
        wrapper = method_source.method(@method_name)

        lambda do |context|
          wrapper.call(context[:data], context[:meta]) do
            flow.call(nil, context: context)
          end
        end
      end
    end
  end
end
