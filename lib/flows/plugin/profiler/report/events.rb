module Flows
  module Plugin
    module Profiler
      class Report
        # @api private
        Event = Struct.new(:method_class, :method_type, :method_name, :data) do
          def subject
            "#{method_class}#{delimeter}#{method_name}"
          end

          private

          def delimeter
            case method_type
            when :instance then '#'
            when :singleton then '.'
            end
          end
        end

        # @api private
        #
        # Method execution start event.
        class StartEvent < Event
          def to_s
            "start: #{subject}"
          end
        end

        # @api private
        #
        # Method execution finish event.
        #
        # Data is an execution time in microseconds.
        class FinishEvent < Event
          def to_s
            "finish(#{data} microseconds): #{subject}"
          end
        end
      end
    end
  end
end
