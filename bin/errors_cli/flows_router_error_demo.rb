module FlowsRouterErrorDemo
  class << self
    include Flows::Result::Helpers

    def call
      router.call(ok(some: :data))
    end

    private

    def router
      Flows::Flow::Router::Custom.new(match_err => :end)
    end
  end
end
