module Flows
  module Operation
    # DSL methods for operation
    module DSL
      attr_reader :steps, :success_shapes, :failure_shapes

      include Flows::Result::Helpers

      def step(name, custom_routes = {})
        @steps << make_step(name, custom_routes: custom_routes)
      end

      def track(name, &block)
        @track = {
          name: name
        }
        @steps << make_step(name, custom_body: ->(**) { ok })
        instance_exec(&block)
        @track = nil
      end

      def success(*keys, **code_keys_map)
        @success_shapes = if keys.empty?
                            code_keys_map
                          else
                            { success: keys }
                          end
      end

      def failure(*keys, **code_keys_map)
        @failure_shapes = if keys.empty?
                            code_keys_map
                          else
                            { failure: keys }
                          end
      end

      private

      def make_step(name, custom_routes: {}, custom_body: nil)
        {
          name: name,
          custom_routes: custom_routes,
          custom_body: custom_body,
          track: @track ? @track[:name] : nil
        }
      end
    end
  end
end
