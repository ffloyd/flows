module Flows
  class SharedContextPipeline
    # @api private
    class RouterDefinition
      def initialize(routes = {})
        @routes = routes
      end

      # :reek:ControlParameter is false positive here
      def to_router(next_step)
        final_routes = @routes.transform_values do |route|
          next route unless route == :next

          next_step || :end
        end

        ::Flows::Flow::Router::Custom.new(final_routes)
      end
    end
  end
end
