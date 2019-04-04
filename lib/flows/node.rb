module Flows
  # Representation of FSM node.
  class Node
    attr_reader :name,
                :body,
                :router

    def initialize(name, body:, router:)
      @name = name
      @body = body
      @router = router
    end

    def call(input:, context:)
      output = body.call(input)

      route = resolve_route(output, context)

      [output, route]
    end

    private

    def resolve_route(output, context)
      matched_entry = router.find do |predicate, _|
        if predicate.respond_to?(:call)
          predicate.call(output, context)
        else
          predicate === output # rubocop:disable Style/CaseEquality
        end
      end

      raise Error, 'no route found' unless matched_entry

      matched_entry[1]
    end
  end
end
