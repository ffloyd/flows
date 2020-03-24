module Flows
  class Flow
    # Node is the main building block for {Flow}.
    #
    # Node is an object which can be executed ({#call}) with some input and execution context
    # and produce output and the next route.
    #
    # Node execution consists of 4 sequential parts:
    #
    # 1. Pre-processor execution (if pre-processor defined).
    #   Allows to modify input which will be transferred to the node's body.
    #   Allows to modify execution context.
    #   Has access to the node's metadata.
    # 2. Body execution. Body is a lambda which receives input and returns output.
    # 3. Post-processor execution (if post-processor defined).
    #   Allows to modify output which was produced by the node's body.
    #   Allows to modify execution context.
    #   Has access to the node's metadata.
    # 4. {Router} execution to determine next node name.
    #
    # Execution result consists of 2 parts: output and next route.
    #
    # ## Pre/postprocessors
    #
    # Both have similar signatures:
    #
    #     preprocessor = lambda do |node_input, context, meta|
    #       # returns input for the BODY
    #       # format [args, kwargs]
    #     end
    #
    #     postprocessor = lambda do |body_output, context, meta|
    #       # returns output of the NODE
    #     end
    #
    # Types for body input and `body_output` is under your control.
    # It allows you to adopt node for very different kinds of bodies.
    #
    # Without pre-processor `input` from {#call} becomes the first and single argument for the body.
    # In the cases when your body expects several arguments or keyword arguments
    # you must use pre-processor. Pre-processor returns array of 2 elements -
    # arguments and keyword arguments. There are some examples of a post-processor return
    # and the corresponding body call:
    #
    #     [[1, 2], {}]
    #     body.call(1, 2)
    #
    #     [[], { a: 1, b: 2}]
    #     body.call(a: 1, b: 2)
    #
    #     [[1, 2], { x: 3, y: 4 }]
    #     body.call(1, 2, x: 3, y: 4)
    #
    #     [[1, 2, { 'a' => 3}], {}]
    #     body.call(1, 2, 'a' => 3)
    #
    # There were simpler solutions, but after [this](https://www.ruby-lang.org/en/news/2019/12/12/separation-of-positional-and-keyword-arguments-in-ruby-3-0/)
    # it's the most clear one.
    #
    # `context` and `meta` are expected to be Ruby Hashes.
    #
    # * `context` - is an execution context and it's mutable.
    #   Execution context is defined outside and not controlled by a node.
    #   Therefore, your mutations will be visible after a node execution.
    # * `meta` - is node execution metadata and it's immutable, read only and node-local.
    #   Designed to store purely technical information like
    #   node name or, maybe, some dependency injection entities.
    #
    # ## Metadata and node names
    #
    # As you may see any Node instance has no name.
    # It's done for the reason: name is not part of a node;
    # it allows to use the same node instance under different names.
    # In the most cases we don't need this, but it's nice to have such ability.
    #
    # In some cases we want to have a node name inside pre/postprocessors.
    # For such cases `meta` is the right place to store node name:
    #
    #     Flows::Flow::Node.new(body: body, router: router, meta: { name: :step_a })
    #
    # @see Flows::Flow some examples here
    class Node
      # Node metadata, a frozen Ruby Hash.
      attr_reader :meta

      # @param body [Proc] node body
      # @param router [Router] node router
      # @param meta [Hash] node metadata
      # @param preprocessor [Proc, nil] pre-processor for the node's body
      # @param postprocessor [Proc, nil] post-processor for the node's body
      def initialize(body:, router:, meta: {}, preprocessor: nil, postprocessor: nil)
        @body = body
        @router = router

        @meta = meta.freeze

        @preprocessor = preprocessor
        @postprocessor = postprocessor
      end

      # Executes the node.
      #
      # @param input [Object] input for a node. In the context of {Flow}
      #   it's initial input or output of the previously executed node.
      #
      # @param context [Hash] execution context. In case of {Flow}
      #   shared between node executions.
      #
      # @return [Array<(Object, Symbol)>] output of a node and next route.
      #
      # `:reek:TooManyStatements` is disabled for this method because even
      # one more call to a private method impacts performance here.
      def call(input, context:)
        output = if @preprocessor
                   args, kwargs = @preprocessor.call(input, context, @meta)
                   @body.call(*args, **kwargs)
                 else
                   @body.call(input)
                 end
        output = @postprocessor.call(output, context, @meta) if @postprocessor

        route = @router.call(output, context: context, meta: @meta)

        [output, route]
      end
    end
  end
end
