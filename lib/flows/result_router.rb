module Flows
  # Node router for simple case when result must be a `Flows::Result`
  # and we don't care about resukt status key
  class ResultRouter
    def initialize(success_route, failure_route)
      @success_route = success_route
      @failure_route = failure_route
    end

    def call(output, **)
      output.ok? ? @success_route : @failure_route
    end
  end
end
