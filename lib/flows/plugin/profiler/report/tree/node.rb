module Flows
  module Plugin
    module Profiler
      class Report
        class Tree < Report
          # @api private
          class Node
            attr_reader :subject
            attr_reader :executions

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
              @children.values
            end

            def register_execution(microseconds)
              @executions << microseconds
            end
          end
        end
      end
    end
  end
end
