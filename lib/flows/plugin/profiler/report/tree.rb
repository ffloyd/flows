require_relative 'tree/node'
require_relative 'tree/calculated_node'

module Flows
  module Plugin
    module Profiler
      class Report
        # Tree report. Merges similar calls, saves execution structure (who called whom).
        #
        # @example
        #     Flows::Plugin::Profiler.profile(:tree) do
        #       # some code here
        #     end
        #
        #     puts Flows::Plugin::Profiler.last_report
        class Tree < Report
          # Returns tree report as Ruby data structs.
          #
          # @return [Array<Hash>] tree report.
          #
          # @example
          #   [
          #     {
          #       subject: 'MyClass#call',
          #       count: 2,
          #       total_ms: 100.0,
          #       total_self_ms: 80.0,
          #       total_self_percentage: 80.0,
          #       avg_ms: 50.0,
          #       avg_self_ms: 40.0,
          #       nested: [
          #         {
          #           subject: 'MyClass#another_method',
          #           count: 1,
          #           total_ms: 20.0,
          #           total_self_ms: 20.0,
          #           total_self_percentage: 20.0,
          #           avg_ms: 20.0,
          #           avg_self_ms: 20.0,
          #           nested: []
          #         }
          #       ]
          #     }
          #   ]
          def to_a
            root_calculated_node.children.map { |node| node.to_h(root_calculated_node) }
          end

          def add(*)
            forget_memoized_values
            super
          end

          def to_s
            root_calculated_node.children.map { |node| node.to_s(root_calculated_node) }.join
          end

          private

          def forget_memoized_values
            @root_node = nil
            @root_calculated_node = nil
          end

          def root_calculated_node
            @root_calculated_node ||= CalculatedNode.new(root_node)
          end

          def root_node
            @root_node ||= Node.new(subject: :ROOT).tap do |root_node|
              events.each_with_object([root_node]) do |event, node_path|
                current_node = node_path.last

                case event
                when StartEvent then process_start_event(node_path, current_node, event)
                when FinishEvent then process_finish_event(node_path, current_node, event)
                end
              end
            end
          end

          # :reek:UtilityFunction
          def process_start_event(node_path, current_node, event)
            node_path << current_node[event.subject]
          end

          # :reek:UtilityFunction :reek:FeatureEnvy
          def process_finish_event(node_path, current_node, event)
            raise 'Invalid profiling events detected' if event.subject != current_node.subject

            current_node.register_execution(event.data)
            node_path.pop
          end
        end
      end
    end
  end
end
