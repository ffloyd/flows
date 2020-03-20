module Flows
  # Simple sequential flow
  class Flow
    def initialize(start_node:, node_map:)
      @start_node = start_node
      @node_map = node_map
    end

    def call(input, context:)
      current_node_name = @start_node

      while current_node_name != :term
        input, current_node_name = @node_map[current_node_name].call(input, context: context)
      end

      input
    end
  end
end
