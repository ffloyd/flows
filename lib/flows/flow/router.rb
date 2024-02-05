module Flows
  class Flow
    # @abstract
    #
    # Node router: defines rules to calculate next {Node} to execute inside a particular {Flow}.
    #
    # Router receives {Flows::Result} Object, execution context and execution metadata.
    # Basing on this information a router must decide what to execute next or
    # decide to stop execution of a flow.
    #
    # If router returns `:end` - it stops an execution process.
    #
    # @!method call( result )
    #   @abstract
    #   @param result [Flows::Result] Result Object, output of a {Node} execution.
    #   @return [Symbol] name of the next node or  a special symbol `:end`.
    #   @raise [NoRouteError] if cannot determine a route.
    #
    # @!method destinations
    #   @abstract
    #   @return [Array<Symbol>] names of all the possible destination nodes
    class Router; end # rubocop:disable Lint/EmptyClass
  end
end

require_relative 'router/errors'
require_relative 'router/simple'
require_relative 'router/custom'
