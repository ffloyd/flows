# rubocop:disable Style/Documentation
# ^^^ it is false positive here

module Flows
  class SharedContextPipeline
    EMPTY_ARRAY = [].freeze

    # @api private
    Step = Struct.new(:name, :lambda, :next_step, keyword_init: true) do
      def to_node(method_source) # rubocop:disable Metrics/MethodLength
        klass = self.class

        Flows::Flow::Node.new(
          body: lambda || method_source.method(name),
          router: Flows::Flow::Router::Custom.new(
            Flows::Result::Ok => next_step || :end,
            Flows::Result::Err => :end
          ),
          meta: { name: name },
          preprocessor: klass::NODE_PREPROCESSOR,
          postprocessor: klass::NODE_POSTPROCESSOR
        )
      end
    end

    Step.const_set(
      :NODE_PREPROCESSOR,
      lambda do |_input, context, meta|
        context[:last_step] = meta[:name]

        [EMPTY_ARRAY, context[:data]]
      end
    )

    Step.const_set(
      :NODE_POSTPROCESSOR,
      lambda do |output, context, _meta|
        context[:data].merge!(output.instance_variable_get(:@data))

        output
      end
    )
  end
end

# rubocop:enable Style/Documentation
