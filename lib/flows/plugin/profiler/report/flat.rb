require_relative 'flat/method_report'

module Flows
  module Plugin
    module Profiler
      class Report
        # Flat report. Merges similar calls, hides execution structure.
        #
        # It's a variation of a {Rport::Tree} where all calls of the same method
        # are combined into a one first-level entry.
        #
        # @example
        #     Flows::Plugin::Profiler.profile(:flat) do
        #       # some code here
        #     end
        #
        #     puts Flows::Plugin::Profiler.last_report
        class Flat < Tree
          def to_a
            method_reports.map(&:to_h)
          end

          def to_s
            method_reports.map(&:to_s).join("\n")
          end

          private

          def method_reports
            @method_reports ||= root_calculated_node
                                .group_by_subject
                                .values
                                .map { |nodes| MethodReport.new(root_calculated_node, *nodes) }
                                .sort_by(&:total_self_ms)
                                .reverse
          end
        end
      end
    end
  end
end
