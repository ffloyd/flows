module Flows
  # Node router: defines predicate rules to calculate next node.
  class Router
    class Error < Flows::Error; end
    class NoRouteError < Error; end

    DEFAULT_PREPROCESSOR = ->(output, _context, _meta) { output }

    def initialize(route_hash, preprocessor: DEFAULT_PREPROCESSOR)
      @route_def = route_hash
      @preprocessor = preprocessor
    end

    def call(output, context:, meta:)
      data = @preprocessor.call(output, context, meta)

      matched_entry = @route_def.find do |predicate, _|
        predicate === data # rubocop:disable Style/CaseEquality
      end

      raise NoRouteError, "no route found found for output: #{output.inspect}" unless matched_entry

      matched_entry[1]
    end
  end
end
