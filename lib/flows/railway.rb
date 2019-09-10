require_relative './railway/errors'

require_relative './railway/dsl'
require_relative './railway/builder'
require_relative './railway/executor'

module Flows
  # Railway DSL
  module Railway
    def self.included(mod)
      mod.extend ::Flows::Railway::DSL
    end

    include ::Flows::Result::Helpers

    def initialize(method_source: nil, deps: {})
      _flows_do_checks

      flow = _flows_make_flow(method_source || self, deps)
      @_flows_executor = _flows_make_executor(flow)
    end

    def call(**params)
      @_flows_executor.call(**params)
    end

    private

    def _flows_do_checks
      raise NoStepsError if self.class.steps.empty?
    end

    def _flows_make_flow(method_source, deps)
      ::Flows::Railway::Builder.new(
        steps: self.class.steps,
        method_source: method_source,
        deps: deps
      ).call
    end

    def _flows_make_executor(flow)
      ::Flows::Railway::Executor.new(
        flow: flow,
        class_name: self.class.name
      )
    end
  end
end
