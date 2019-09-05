module Flows
  # Node router: defines predicate rules to calculate next node.
  class Router
    class Error < Flows::Error; end
    class NoRouteError < Error; end

    def initialize(route_hash, preprocessor: nil)
      @route_def = route_hash
      @preprocessor = preprocessor
    end

    def call(output, context:, meta:)
      data = @preprocessor ? @preprocessor.call(output, context, meta) : output

      @route_def.each_pair do |predicate, route|
        return route if predicate === data # rubocop:disable Style/CaseEquality
      end

      raise NoRouteError, "no route found found for output: #{output.inspect}"
    end
  end
end
