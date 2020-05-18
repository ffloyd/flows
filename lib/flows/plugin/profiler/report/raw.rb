module Flows
  module Plugin
    module Profiler
      class Report
        # Raw report. Preserves events as is.
        class Raw < Report
          # @see Report#to_s
          def to_s
            raw_data.map(&:to_s).join("\n")
          end
        end
      end
    end
  end
end
