module Flows
  module Operation
    # DSL methods for operation
    module DSL
      attr_reader :steps, :ok_shapes, :err_shapes

      include Flows::Result::Helpers

      def step(name, custom_body_or_routes = nil, custom_routes = nil)
        if custom_routes
          custom_body = custom_body_or_routes
        elsif custom_body_or_routes.is_a? Hash
          custom_routes = custom_body_or_routes
          custom_body = nil
        else
          custom_routes = nil
          custom_body = custom_body_or_routes
        end

        @steps << make_step(name, custom_routes: custom_routes, custom_body: custom_body)
      end

      def track(name, &block)
        track_path_before = @track_path
        @track_path += [name]

        @steps << make_step(name, custom_body: ->(**) { ok })
        instance_exec(&block)

        @track_path = track_path_before
      end

      def wrap(name, custom_body = nil, &block)
        @steps << make_step(name, type: :wrapper, custom_body: custom_body, block: block)
      end

      def ok_shape(*keys, **code_keys_map)
        @ok_shapes = if keys.empty?
                       code_keys_map
                     else
                       { success: keys }
                     end
      end

      def err_shape(*keys, **code_keys_map)
        @err_shapes = if keys.empty?
                        code_keys_map
                      else
                        { failure: keys }
                      end
      end

      def no_shape
        @ok_shapes = :no_shapes
        @err_shapes = :no_shapes
      end

      private

      def make_step(name, type: :step, custom_routes: {}, custom_body: nil, block: nil)
        {
          type: type,
          name: name,
          custom_routes: custom_routes,
          custom_body: custom_body,
          block: block,
          track_path: @track_path
        }
      end
    end
  end
end
