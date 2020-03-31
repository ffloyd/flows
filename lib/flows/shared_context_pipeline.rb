require_relative 'shared_context_pipeline/errors'
require_relative 'shared_context_pipeline/step'
require_relative 'shared_context_pipeline/mutation_step'
require_relative 'shared_context_pipeline/step_list'
require_relative 'shared_context_pipeline/dsl'

module Flows
  # Abstraction for organizing calculations in a shared data context.
  #
  # Let's start with example. Let's say we have to calculate `(a + b) * (a - b)`:
  #
  #     class Claculation < Flows::SharedContextPipeline
  #       step :calc_left_part
  #       step :calc_right_part
  #       step :calc_result
  #
  #       def calc_left_part(a:, b:, **)
  #         ok(left: a + b)
  #       end
  #
  #       def calc_right_part(a:, b:, **)
  #         ok(right: a - b)
  #       end
  #
  #       def calc_result(left:, right:, **)
  #         ok(result: left * right)
  #       end
  #     end
  #
  #     x = Calculation.call(a: 1, b: 2)
  #     # x is a `Flows::Result::Ok`
  #
  #     x.unwrap
  #     # => { a: 1, b: 2, left: 3, right: -1, result: -3 }
  #
  # It works by the following rules:
  #
  # * execution context is a Hash with Symbol keys.
  # * input becomes initial execution context.
  # * steps are executed in a provided order.
  # * actual execution context becomes a step input.
  # * step implementation is a public method with the same name.
  # * step implementation must return {Flows::Result} ({Flows::Result::Helpers} already included).
  # * Result Object data will be merged to shared context after each step execution.
  # * If returned Result Object is successful - next step will be executed,
  #   in the case of the last step a calculation will be finished
  # * If returned Result Object is failure - a calculation will be finished
  # * When calculation is finished a Result Object will be returned:
  #     * result will have the same type and status as in the last executed step result
  #     * result wull have a full execution context as data
  #
  # ## Mutation Steps
  #
  # You may use a different step definition way:
  #
  #     class MyClass < Flows::SharedContextPipeline
  #       mut_step :hello
  #
  #       def hello(ctx)
  #         ctx[:result] = 'hello'
  #       end
  #     end
  #
  # When you use `mut_step` DSL method you define a step with different rules for implementation:
  #
  # * step implementation receives _one_ argument and it's your execution context in a form of a mutable Hash
  # * step implementation can modify execution context
  # * if step implementation returns
  #     * "truly" value - it makes step successful with default status `:ok`
  #     * "falsey" value - it makes step failure with default status `:err`
  #     * {Result} - it works like for standard step, but data is ignored. Only result type and status have effect.
  class SharedContextPipeline
    extend ::Flows::Ext::ImplicitInit

    include ::Flows::Result::Helpers
    extend ::Flows::Result::Helpers

    extend DSL

    def initialize
      steps = self.class.steps

      @__flows_railway_flow = Flows::Flow.new(
        start_node: steps.first_step_name,
        node_map: steps.to_node_map(self)
      )
    end

    # Executes pipeline with provided keyword arguments, returns Result Object.
    #
    # @return [Flows::Result]
    def call(**kwargs)
      context = { data: kwargs }

      result = @__flows_railway_flow.call(nil, context: context)

      result.class.new(
        context[:data],
        status: result.status,
        meta: { last_step: context[:last_step] }
      )
    end
  end
end
