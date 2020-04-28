module FlowErrorDemo
  class << self
    def no_first_node
      Flows::Flow.new(
        start_node: :first,
        node_map: {}
      )
    end

    def invalid_node_route
      Flows::Flow.new(
        start_node: :first,
        node_map: {
          first: Flows::Flow::Node.new(
            body: ->(_) {},
            router: Flows::Flow::Router::Custom.new(a: :b)
          )
        }
      )
    end
  end
end
