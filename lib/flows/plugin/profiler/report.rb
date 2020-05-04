require_relative 'report/events'
require_relative 'report/raw'

module Flows
  module Plugin
    module Profiler
      # Base class for {Profiler} reports.
      #
      # @!method to_s
      #   @abstract
      #   @return [String] human-readable representation.
      class Report
        # @return [Array<Array>] raw profiler events
        attr_reader :raw_data

        def initialize
          @raw_data = []
        end

        # Add event to profile report.
        #
        # @param event_type [:started, :finished] event type
        # @param klass [Class] class where called method is placed
        # @param method_type [:instance, :singleton] method type
        # @param method_name [Symbol] name of the called method
        # @param data [nil, Float] event data, time represented as
        #   a Float microseconds value.
        def add(*args)
          raw_data << args
        end

        # @return [Array<Event>] array of events
        def to_a
          raw_data.map do |raw_event|
            klass = case raw_event.first
                    when :started then StartEvent
                    when :finished then FinishEvent
                    end

            klass.new(*raw_event[1..-1])
          end
        end
      end
    end
  end
end
