module Flows
  module Plugin
    module Profiler
      class Report
        # Raw report. Preserves events as is.
        class Raw < Report
          # @return [Array<Array>] raw profiler events
          attr_reader :raw_data
          alias to_a raw_data

          def initialize
            @raw_data = []
          end

          # @see Report#add
          def add(*args)
            raw_data << args
          end

          # @see Report#to_s
          def to_s
            raw_data.map { |event| render_event(*event) }.join("\n")
          end

          private

          # :reek:ControlParameter
          # :reek:LongParameterList
          # :reek:TooManyStatements
          def render_event(event_type, klass, method_type, method_name, data)
            delimeter = case method_type
                        when :instance then '#'
                        when :singleton then '.'
                        end

            subject = "#{klass}#{delimeter}#{method_name}"

            event_msg = case event_type
                        when :started then 'started:'
                        when :finished then "finished(#{data} microseconds):"
                        end

            "#{event_msg} #{subject}"
          end
        end
      end
    end
  end
end
