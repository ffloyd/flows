module Flows
  # Representation of FSM node.
  # TODO: rename to `Flows::Flow::Node`
  # TODO: remove `name` attr because name is useless inside implementation
  # also it will shut up :reek:TooManyInstanceVariables
  class Node
    attr_reader :name, :meta

    def initialize(name:, body:, router:, meta: {}, preprocessor: nil, postprocessor: nil)
      @name = name
      @body = body
      @router = router

      @meta = meta.freeze

      @preprocessor = preprocessor
      @postprocessor = postprocessor
    end

    def call(input, context:)
      input  = @preprocessor.call(input, context, @meta) if @preprocessor
      output = @body.call(input)
      output = @postprocessor.call(output, context, @meta) if @postprocessor

      route = @router.call(output, context: context, meta: @meta)

      [output, route]
    end
  end
end
