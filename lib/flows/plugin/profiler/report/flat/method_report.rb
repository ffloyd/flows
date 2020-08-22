module Flows
  module Plugin
    module Profiler
      class Report
        class Flat < Tree
          # @api private
          class MethodReport
            attr_reader :root_node, :calculated_nodes

            def initialize(root_node, *calculated_nodes)
              @root_node = root_node
              @calculated_nodes = calculated_nodes

              raise 'no single node provided' if calculated_nodes.empty?
              raise 'calculated_nodes must be about the same subject' unless nodes_have_same_subject
            end

            def subject
              @subject ||= calculated_nodes.first.subject
            end

            def count
              @count ||= calculated_nodes.map(&:count).sum
            end

            def total_self_ms
              @total_self_ms ||= calculated_nodes.map(&:total_self_ms).sort.sum
            end

            def total_self_percentage
              @total_self_percentage ||= calculated_nodes
                                         .map { |node| node.total_self_percentage(root_node) }
                                         .sort
                                         .sum
            end

            def avg_self_ms
              @avg_self_ms ||= total_self_ms / count
            end

            def direct_subcalls
              @direct_subcalls ||= calculated_nodes
                                   .flat_map { |node| node.children.map(&:subject) }
                                   .uniq
            end

            def to_h
              @to_h ||= {
                subject: subject,
                count: count,
                total_self_ms: total_self_ms,
                total_self_percentage: total_self_percentage,
                avg_self_ms: avg_self_ms,
                direct_subcalls: direct_subcalls
              }
            end

            def to_s
              [
                '',
                "- #{subject} -",
                "called:                      #{count} time(s)",
                "total self execution time:   #{total_self_ms.truncate(2)}ms",
                "total self percentage:       #{total_self_percentage.truncate(2)}%",
                "average self execution time: #{avg_self_ms.truncate(2)}ms",
                "direct subcalls:             #{direct_subcalls.join(', ')}"
              ]
            end

            private

            def nodes_have_same_subject
              calculated_nodes.all? { |node| node.subject == subject }
            end
          end
        end
      end
    end
  end
end
