require_relative './railway/errors'

require_relative './railway/step'
require_relative './railway/step_list'
require_relative './railway/dsl'
require_relative './railway/builder'
require_relative './railway/executor'

require_relative './ext/implicit_build'
require_relative './ext/inheritable_attrs'

module Flows
  # Railway DSL
  class Railway
    extend ::Flows::Railway::DSL
    extend ::Flows::Ext::ImplicitBuild

    include ::Flows::Result::Helpers

    def initialize(method_source: nil, deps: {})
      _flows_do_checks

      method_source ||= self
      flow = _flows_make_flow(method_source, deps)

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
