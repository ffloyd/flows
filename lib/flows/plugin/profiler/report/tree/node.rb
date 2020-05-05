module Flows
  module Plugin
    module Profiler
      class Report
        class Tree < Report
          # @api private
          class Node
            MICROSECONDS_IN_MILLISECOND = 1000.0

            attr_reader :subject

            def initialize(subject:)
              @subject = subject
              @children = {}
              @cache = {}

              @executions = []
            end

            def [](subject)
              @children[subject] ||= Node.new(subject: subject)
            end

            def children
              @children.values.sort_by(&:total_ms).reverse
            end

            def register_execution(microseconds)
              @executions << microseconds
              @cache = {}
            end

            def count
              @cache[:count] ||= @executions.count
            end

            def total_ms
              @cache[:total_ms] ||= @executions.sort.sum / MICROSECONDS_IN_MILLISECOND
            end

            def avg_ms
              @cache[:avg_ms] ||= total_ms / count
            end

            def children_ms
              @cache[:children_ms] ||= children.map(&:total_ms).sort.sum
            end

            def total_self_ms
              @cache[:total_self_ms] ||= total_ms - children_ms
            end

            def total_self_percentage(root_node = self)
              @cache[:total_self_percentage] ||= total_self_ms / root_node.children_ms * 100.0
            end

            def total_percentage(root_node = self)
              @cache[:total_percentage] ||= total_ms / root_node.children_ms * 100.0
            end

            def avg_self_ms
              @cache[:avg_self_ms] ||= total_self_ms / count
            end

            def to_h(root_node = self) # rubocop:disable Metrics/MethodLength
              {
                subject: subject,
                count: count,
                total_ms: total_ms,
                total_percentage: total_percentage(root_node),
                total_self_ms: total_self_ms,
                total_self_percentage: total_self_percentage(root_node),
                avg_ms: avg_ms,
                avg_self_ms: avg_self_ms,
                nested: children.map { |node| node.to_h(root_node) }
              }
            end

            def to_s(root_node = self)
              (base_text_list(root_node) + childeren_text_list(root_node)).join("\n")
            end

            private

            def base_text_list(root_node) # rubocop:disable Metrics/MethodLength
              [
                '',
                "- #{subject} -",
                "called:                      #{count} time(s)",
                "total execution time:        #{total_ms.truncate(2)}ms",
                "total percentage:            #{total_percentage(root_node).truncate(2)}%",
                "total self execution time:   #{total_self_ms.truncate(2)}ms",
                "total self percentage:       #{total_self_percentage(root_node).truncate(2)}%",
                "average execution time:      #{avg_ms.truncate(2)}ms",
                "average self execution time: #{avg_self_ms.truncate(2)}ms"
              ]
            end

            def childeren_text_list(root_node)
              return [] if @children.empty?

              children.map { |node| node.to_s(root_node) }
                      .join("\n")
                      .split("\n")
                      .map { |str| '|    ' + str }
            end
          end
        end
      end
    end
  end
end
