module Flows
  # Node router: defines predicate rules to calculate next node.
  class Router
    DEFAULT_PREPROCESSOR = ->(output, _context) { output }

    def initialize(route_hash, preprocessor: DEFAULT_PREPROCESSOR)
      @route_def = route_hash
      @preprocessor = preprocessor
    end

    def call(input, context:)
      data = @preprocessor.call(input, context)

      matched_entry = @route_def.find do |predicate, _|
        if predicate.respond_to?(:call)
          predicate.call(data)
        else
          predicate === data # rubocop:disable Style/CaseEquality
        end
      end

      raise Error, 'no route found' unless matched_entry

      matched_entry[1]
    end
  end
end
