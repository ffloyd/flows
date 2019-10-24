module Flows
  class Railway
    # Step bla
    class Step
      attr_reader :name, :body, :next_step

      NODE_PREPROCESSOR = ->(input, _, _) { input.unwrap }

      NODE_POSTPROCESSOR = lambda do |output, context, meta|
        context[:last_step] = meta[:name]

        output
      end

      def initialize(name:, body:, next_step:)
        @name = name
        @body = body
        @next_step = next_step
      end

      def to_node
        Flows::Node.new(
          name: name,
          body: body,
          preprocessor: NODE_PREPROCESSOR,
          postprocessor: NODE_POSTPROCESSOR,
          router: Flows::ResultRouter.new(next_step, :term),

          meta: { name: name }
        )
      end
    end
  end
end
