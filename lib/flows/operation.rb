require_relative 'operation/errors'

require_relative 'operation/dsl'
require_relative 'operation/builder'
require_relative 'operation/executor'

module Flows
  # Operaion DSL
  module Operation
    def self.included(mod)
      mod.instance_variable_set(:@steps, [])
      mod.extend ::Flows::Operation::DSL
    end

    include ::Flows::Result::Helpers

    def initialize
      _flows_do_checks

      @_flows_executor = _flows_make_executor(_flows_make_flow)
    end

    def call(**params)
      @_flows_executor.call(**params)
    end

    private

    def _flows_do_checks
      raise NoStepsError if self.class.steps.empty?
      raise NoSuccessShapeError, self if self.class.success_shapes.nil?
    end

    def _flows_make_flow
      ::Flows::Operation::Builder.new(
        steps: self.class.steps,
        method_source: self
      ).call
    end

    def _flows_make_executor(flow)
      ::Flows::Operation::Executor.new(
        flow: flow,
        success_shapes: self.class.success_shapes,
        failure_shapes: self.class.failure_shapes,
        class_name: self.class.name
      )
    end
  end
end
