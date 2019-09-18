module Flows
  # Simple sequential flow
  class Flow
    def initialize(start_node:, nodes:)
      @start_node = start_node
      @nodes = Hash[
        nodes.map { |node| [node.name, node] }
      ]
    end

    def call(input, context:)
      current_node_name = @start_node

      while current_node_name != :term
        input, current_node_name = @nodes[current_node_name].call(input, context: context)
      end

      input
    end
  end
end
