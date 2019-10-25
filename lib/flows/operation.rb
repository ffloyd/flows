require_relative 'operation/errors'

require_relative 'operation/dsl'
require_relative 'operation/builder'
require_relative 'operation/executor'

module Flows
  # Operation DSL
  class Operation
    extend ::Flows::Operation::DSL
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
      klass = self.class

      raise NoStepsError if klass.steps.empty?
      raise NoSuccessShapeError, self if klass.ok_shapes.nil?
    end

    def _flows_make_flow(method_source, deps)
      ::Flows::Operation::Builder.new(
        steps: self.class.steps,
        method_source: method_source,
        deps: deps
      ).call
    end

    def _flows_make_executor(flow)
      klass = self.class

      ::Flows::Operation::Executor.new(
        flow: flow,
        ok_shapes: klass.ok_shapes,
        err_shapes: klass.err_shapes,
        class_name: klass.name
      )
    end
  end
end
