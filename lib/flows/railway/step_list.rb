module Flows
  class Railway
    # @api private
    class StepList
      def initialize
        @list = []
      end

      def initialize_dup(_other)
        @list = @list.map(&:dup)
      end

      def add(name:, lambda: nil)
        step = Step.new(name: name, lambda: lambda)
        last_step = @list.last

        last_step.next_step = name if last_step

        @list << step

        self
      end

      def first_step_name
        @list.first.name
      end

      # `:reek:FeatureEnvy` is false positive here.
      def to_node_map(method_source)
        @list.to_h { |step| [step.name, step.to_node(method_source)] }
      end

      def empty?
        @list.empty?
      end
    end
  end
end
