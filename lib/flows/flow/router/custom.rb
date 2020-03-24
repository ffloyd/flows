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
      # ## Preprocessing
      #
      # You can build your own Result Object for routing basing on original Result Object,
      # execution context and execution meta. To do this you have to provide preprocessor to {#initialize}.
      #
      # ## How does routing work?
      #
      # It relies on the Ruby behaviour for procs, lambdas and Case Equality:
      #
      #     predicate = ->(x) { x > 5 }
      #
      #     predicate.call(5)
      #     # => false
      #
      #     predicate.call(10)
      #     # => true
      #
      #     predicate === 5
      #     # => false
      #
      #     predicate === 10
      #     # => true
      #
      #     case 5
      #     when predicate then 'Yes'
      #     else 'No'
      #     end
      #     # => 'No'
      #
      #     case 10
      #     when predicate then 'Yes'
      #     else 'No'
      #     end
      #     # => 'Yes'
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
      class Custom < Router
        # Creates a new custom router from route table and optional preprocessor.
        #
        # Preprocessor must have the following structure:
        #
        #     lambda do |result, context, meta|
        #       # returns Flows::Result for matching in routes table
        #     end
        #
        # @note Preprocessor must not mutate original Result Object.
        #   {Flows::Node} pre/postprocessing is the right place for it.
        #
        # @see Flows::Flow::Node Pre/postprocessing of data must be done in Node.
        #
        # @param routes [Hash<Proc, Symbol>] route table.
        # @param preprocessor [Proc, nil] preprocessor lambda or nil.
        def initialize(routes:, preprocessor: nil)
          @route_def = routes
          @preprocessor = preprocessor
        end

        # @see Flows::Flow::Router#call
        def call(output, context:, meta:)
          data = @preprocessor ? @preprocessor.call(output, context, meta) : output

          @route_def.each_pair do |predicate, route|
            return route if predicate === data # rubocop:disable Style/CaseEquality
          end

          raise NoRouteError, "no route found for: #{output.inspect}"
        end
      end
    end
  end
end
