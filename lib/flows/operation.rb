require_relative 'operation/errors'

require_relative 'operation/dsl'
require_relative 'operation/builder'
require_relative 'operation/executor'

require_relative 'implicit_build'

module Flows
  # Operation DSL
  module Operation
    def self.included(mod)
      mod.extend ::Flows::Operation::DSL
      mod.extend ::Flows::ImplicitBuild
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
      raise NoSuccessShapeError, self if self.class.ok_shapes.nil?
    end

    def _flows_make_flow(method_source, deps)
      ::Flows::Operation::Builder.new(
        steps: self.class.steps,
        method_source: method_source,
        deps: deps
      ).call
    end

    def _flows_make_executor(flow)
      ::Flows::Operation::Executor.new(
        flow: flow,
        ok_shapes: self.class.ok_shapes,
        err_shapes: self.class.err_shapes,
        class_name: self.class.name
      )
    end
  end
end
