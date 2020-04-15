require_relative 'shared_context_pipeline/errors'
require_relative 'shared_context_pipeline/router_definition'
require_relative 'shared_context_pipeline/step'
require_relative 'shared_context_pipeline/mutation_step'
require_relative 'shared_context_pipeline/track'
require_relative 'shared_context_pipeline/track_list'
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
  #
  # ## Tracks & Routes
  #
  # In some situations you may want some branching in a mix. Let's provide an example for a common problem
  # when you have to do some additional steps in case of multiple types of errors.
  # Let's say report to some external system:
  #
  #     class SafeFetchComment < Flows::SharedContextPipeline
  #       step :fetch_post, routes(
  #         match_ok => :next,
  #         match_err => :handle_error
  #       )
  #       step :fetch_comment, routes(
  #         match_ok => :next,
  #         match_err => :handle_error
  #       )
  #
  #       track :handle_error do
  #         step :report_to_external_system
  #         step :write_logs
  #       end
  #
  #       # steps implementations here
  #     end
  #
  # Let's describe how `routes(...)` and `track` DSL methods work.
  #
  # Each step has a router. Router is defined by a hash and `router(...)` method itself is
  # a (almost) shortcut to {Flows::Flow::Router::Custom} constructor. By default each step has the following
  # router definition:
  #
  #     {
  #       match_ok => :next, # next step is calculated by DSL, this symbol will be substituted in a final router
  #       match_err => :end  # `:end` means stop execution
  #     }
  #
  # Hash provided in `router(...)` method will override default hash to make a final router.
  #
  # Because of symbols with special behavior (`:end`, `:next`) you cannot name your steps or tracks
  # `:next` or `:end`. And this is totally ok because it is reserved words in Ruby.
  #
  # By the way, you can route not only to tracks, but also to steps. And by using `match_ok(status)` and
  # `match_err(status)` you can have different routes for different statuses of successful or failure results.
  #
  # Steps defined inside a track are fully isolated. The simple way is to think about track as a totally
  # separate pipeline. You have to explicitly enter to it. And explicitly return from it to root-level steps
  # if you want to continue execution.
  #
  # If you feel it's too much verbose to route many steps to the same track you can do something like this:
  #
  #     class SafeFetchComment < Flows::SharedContextPipeline
  #       def self.safe_step(name)
  #         step name, routes(
  #           match_ok => :next,
  #           match_err => :handle_error
  #         )
  #       end
  #
  #       safe_step :fetch_post
  #       safe_step :fetch_comment
  #
  #       track :handle_error do
  #         step :report_to_external_system
  #         step :write_logs
  #       end
  #
  #       # steps implementations here
  #     end
  #
  # ## Callbacks
  #
  # You may want to have some logic to execute before all steps, or after all, or before each, or after each.
  # For example to inject generalized execution process logging.
  # To achieve this you can use callbacks:
  #
  #     class MySCP < Flows::SharedContextPipeline
  #       before_all do |klass, context|
  #         # you can modify execution context here
  #         # return value will be ignored
  #       end
  #
  #       after_all do |klass, pipeline_result|
  #         # you must provide final result object for pipeline here
  #         # if no modifications needed - just return provided pipeline_result
  #       end
  #
  #       before_each do |klass, step_name, context|
  #         # you can modify context here
  #         # return value will be ignored
  #       end
  #
  #       after_each do |klass, step_name, context, step_result|
  #         # you can modify context here
  #         # you must not modify step_result
  #         # context already has data from step_result at the moment of execution
  #         # return value will be ignored
  #       end
  #     end
  class SharedContextPipeline
    extend ::Flows::Plugin::ImplicitInit

    include ::Flows::Result::Helpers
    extend ::Flows::Result::Helpers

    extend DSL

    def initialize
      tracks = self.class.tracks

      @__flow = Flows::Flow.new(
        start_node: tracks.first_step_name,
        node_map: tracks.to_node_map(self)
      )
    end

    # Executes pipeline with provided keyword arguments, returns Result Object.
    #
    # @return [Flows::Result]
    def call(**kwargs) # rubocop:disable Metrics/MethodLength
      klass = self.class
      context = { data: kwargs, class: klass }

      klass.before_all_callbacks.each do |callback|
        callback.call(klass, context[:data])
      end

      flow_result = @__flow.call(nil, context: context)

      final_result = flow_result.class.new(
        context[:data],
        status: flow_result.status,
        meta: { last_step: context[:last_step] }
      )

      klass.after_all_callbacks.reduce(final_result) do |result, callback|
        callback.call(klass, result)
      end
    end
  end
end
