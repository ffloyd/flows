require_relative 'flow/node'
require_relative 'flow/router'

module Flows
  # Abstraction for build [deterministic finite-state machine](https://www.freecodecamp.org/news/state-machines-basics-of-computer-science-d42855debc66/)-like
  # execution objects.
  #
  # Let's refer to 'deterministic finite-state machine' as DFSM.
  #
  # It's NOT an implementation of DFSM. It just shares a lot of
  # structural ideas. You can also think about {Flow} as an [oriented graph](https://en.wikipedia.org/wiki/Graph_(discrete_mathematics)#Oriented_graph),
  # where:
  #
  # * you have the one and only one initial node
  # * you start execution from the initial node
  # * after node execution your are going to some next node or stop execution.
  #
  # And edges formed by possible next nodes.
  #
  # DFSM has a very important property:
  #
  # > From any state, there is only one transition for any allowed input.
  #
  # So, we represent DFSM states as {Node}s. Each {Node}, basing on input (input includes execution context also)
  # performs some side effects and returns output and next {Node} (DFSM state).
  #
  # Side effects here can be spitted into two types:
  #
  # * modification of execution context
  # * rest of them: working with 3rd party libraries, printing to STDOUT, etc.
  #
  # Final state represented by special symbol `:end`.
  #
  # @note You should not use {Flow} in your business code. It's designed to be underlying execution engine
  #   for high-level abstractions. In other words - it's for libraries, not applications.
  #
  # @example Calculates sum of elements in array. If sum more than 10 prints 'Big', otherwise prints 'Small'.
  #
  #     flow = Flows::Flow.new(
  #       start_node: :sum_list,
  #       node_map: {
  #         sum_list: Flows::Flow::Node.new(
  #           body: ->(list) { list.sum },
  #           router: Flows::Flow::Router::Custom.new(
  #             routes: {
  #               ->(x) { x > 10 } => :print_big,
  #               ->(x) { x <= 10 } => :print_small
  #             }
  #           )
  #         ),
  #         print_big: Flows::Flow::Node.new(
  #           body: ->(_) { puts 'Big' },
  #           router: Flows::Flow::Router::Custom.new(
  #             routes: {
  #               nil => :end # puts returns nil.
  #             }
  #           )
  #         ),
  #         print_small: Flows::Flow::Node.new(
  #           body: ->(_) { puts 'Small' },
  #           router: Flows::Flow::Router::Custom.new(
  #             routes: {
  #               nil => :end # puts returns nil.
  #             }
  #           )
  #         )
  #       }
  #     )
  #
  #     flow.call([1, 2, 3, 4, 5], context: {})
  #     # prints 'Big' and returns nil
  class Flow
    # @param start_node [Symbol] name of the entry node.
    # @param node_map [Hash<Symbol, Node>] keys are node names, values are nodes.
    def initialize(start_node:, node_map:)
      @start_node = start_node
      @node_map = node_map
    end

    # Executes a flow.
    #
    # @param input [Object] initial input
    # @param context [Hash] mutable execution context
    # @return [Object] execution result
    def call(input, context:)
      current_node_name = @start_node

      while current_node_name != :end
        input, current_node_name = @node_map[current_node_name].call(input, context: context)
      end

      input
    end
  end
end
