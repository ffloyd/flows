module Flows
  class Flow
    class Router
      # Router with custom rules.
      #
      # Expects routes table in a special format:
      #
      #     {
      #       ->(x) { x.ok? } => :step_a,
      #       ->(x) { x.err? && x.status == :validation_error } => :end,
      #       ->(x) { x.err? } => :handle_error
      #     }
      #
      # Yes, it's confusing. But by including {Flows::Result::Helpers} you can (and should) rewrite it like this:
      #
      #     {
      #       match_ok => :route_a,                 # on success go to step_a
      #       match_err(:validation_error) => :end, # on failure with status `:validation_error` - stop execution
      #       match_err => :handle_error            # on any other failure go to the step handle_error
      #     }
      #
      # So, your routes table is an ordered set of pairs `predicate => route` in form of Ruby Hash.
      #
      # Any time you writing a router table you can imagine that you're writing `case`:
      #
      #     case step_result
      #     when match_ok then :route_a                  # on success go to step_a
      #     when match_err(:validation_error) then :end  # on failure with status `:validation_error` - stop execution
      #     when match_err then :handle_error            # on any other failure go to the step handle_error
      #     end
      #
      # @see Flows::Flow some examples here
      #
      # @see Flows::Flow::Node Pre/postprocessing of data must be done inside Node.
      class Custom < Router
        # Creates a new custom router from a route table.
        #
        # @param routes [Hash<Proc, Symbol>] route table.
        def initialize(routes)
          @routes = routes
        end

        # @see Flows::Flow::Router#call
        def call(result)
          @routes.each_pair do |predicate, route|
            return route if predicate === result # rubocop:disable Style/CaseEquality
          end

          raise NoRouteError, "no route found for: #{result.inspect}"
        end
      end
    end
  end
end
