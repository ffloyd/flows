module Flows
  class Flow
    # Base class for {Flow} error
    class Error < StandardError; end

    # Raised when router has an impossible route.
    class InvalidNodeRouteError < Error
      def initialize(node_name, route_destination)
        @node_name = node_name.inspect
        @route_destination = route_destination.inspect
      end

      def message
        "Node `#{@node_name}` has a route to `#{@route_destination}`, but node `#{@route_destination}` is missing."
      end
    end

    # Raised when router has an impossible route.
    class InvalidFirstNodeError < Error
      def initialize(node_name)
        @node_name = node_name.inspect
      end

      def message
        "`#{@node_name}` is a first node name, but node `#{@node_name}` is missing."
      end
    end
  end
end
