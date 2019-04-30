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

    def call(**params)
      @flows_flow ||= ::Flows::Operation::Builder.new(self).call
      @flows_executor ||= ::Flows::Operation::Executor.new(self, @flows_flow)

      @flows_executor.call(**params)
    end
  end
end
