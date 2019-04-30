module Flows
  module Operation
    # DSL methods for operation
    module DSL
      attr_reader :steps, :success_filter, :failure_filter

      def step(name)
        @steps << {
          name: name
        }
      end

      def success(*keys, **code_keys_map)
        @success_filter = if keys.empty?
                            code_keys_map
                          else
                            { success: keys }
                          end
      end

      def failure(*keys, **code_keys_map)
        @failure_filter = if keys.empty?
                            code_keys_map
                          else
                            { failure: keys }
                          end
      end
    end
  end
end
