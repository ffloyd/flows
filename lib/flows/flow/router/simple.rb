module Flows
  class Flow
    class Router
      # Router with static paths for successful and failure results.
      class Simple < Router
        # @param success_route [Symbol] route for any successful results.
        # @param failure_route [Symbol] route for any failure results.
        def initialize(success_route, failure_route)
          @success_route = success_route
          @failure_route = failure_route
        end

        # @see Flows::Flow::Router#call
        def call(result, **)
          result.ok? ? @success_route : @failure_route
        end
      end
    end
  end
end
