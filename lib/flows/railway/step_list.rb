module Flows
  class Railway
    # Step Definition
    class StepList
      def initialize
        @unprocessed_definitions = []
        @steps = []

        @last_step_name = nil
        @links = {}
      end

      def initialize_dup(_other)
        @unprocessed_definitions = @unprocessed_definitions.map(&:dup)
        @steps = @steps.map(&:dup)
        @links = @links.dup
      end

      def add_step(name:, custom_body:)
        @unprocessed_definitions << { name: name, custom_body: custom_body }

        @links[@last_step_name] = name if @last_step_name
        @last_step_name = name

        self
      end

      def to_a(body_resolver:)
        @unprocessed_definitions.each do |name:, custom_body:|
          @steps << Step.new(
            name: name,
            body: custom_body || body_resolver.call(name),
            next_step: @links[name] || :term
          )
        end

        @unprocessed_definitions.clear
        @steps
      end

      def empty?
        @unprocessed_definitions.empty? && @steps.empty?
      end
    end
  end
end
