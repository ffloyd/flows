module Flows
  class Flow
    class Router
      # Base class for {Flows::Router} error.
      class Error < Flows::Error; end

      # Raised when no route found basing on provided data.
      class NoRouteError < Error; end
    end
  end
end
