module Flows
  class Railway
    # @api private
    Step = Struct.new(:name, :lambda, :next_step, keyword_init: true) do
      NODE_PREPROCESSOR = ->(input, _, _) { [[], input.unwrap] }

      NODE_POSTPROCESSOR = lambda do |output, context, meta|
        context[:last_step] = meta[:name]

        output
      end

      def to_node(method_source)
        Flows::Flow::Node.new(
          body: lambda || method_source.method(name),
          router: Flows::Flow::Router::Simple.new(next_step || :end, :end),
          meta: { name: name },
          preprocessor: NODE_PREPROCESSOR,
          postprocessor: NODE_POSTPROCESSOR
        )
      end
    end
  end
end
