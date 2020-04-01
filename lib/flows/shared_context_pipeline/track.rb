module Flows
  class SharedContextPipeline
    # @api private
    class Track
      TRACK_ENTRY_ROUTER_DEF = RouterDefinition.new(
        Flows::Result::Ok => :next,
        Flows::Result::Err => :end
      )

      def initialize(name)
        @name = name
        @step_list = []
      end

      def initialize_dup(_other)
        @step_list = @step_list.map(&:dup)
      end

      def add_step(name:, lambda: nil, router_def:)
        step = Step.new(name: name, lambda: lambda, router_def: router_def)

        last_step = @step_list.last
        last_step.next_step = name if last_step

        @step_list << step

        self
      end

      def add_mutation_step(name:, lambda: nil, router_def:)
        step = MutationStep.new(name: name, lambda: lambda, router_def: router_def)

        last_step = @step_list.last
        last_step.next_step = name if last_step

        @step_list << step

        self
      end

      def first_step_name
        raise NoStepsError if @step_list.empty?

        @step_list.first.name
      end

      def to_node_map(method_source)
        @step_list.each_with_object(@name => make_track_entry_node) do |step, node_map|
          node_map[step.name] = step.to_node(method_source)
        end
      end

      private

      def make_track_entry_node
        MutationStep.new(
          name: @name,
          lambda: proc { true },
          router_def: TRACK_ENTRY_ROUTER_DEF,
          next_step: first_step_name
        ).to_node(nil)
      end
    end
  end
end
