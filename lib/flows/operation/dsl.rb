module Flows
  module Operation
    # DSL methods for operation
    module DSL
      attr_reader :steps, :success_shapes, :failure_shapes

      def step(name)
        @steps << {
          name: name
        }
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
    end
  end
end
