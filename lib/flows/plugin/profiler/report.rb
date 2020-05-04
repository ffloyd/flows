require_relative 'report/raw'

module Flows
  module Plugin
    module Profiler
      # Base class for {Profiler} reports.
      #
      # @!method add( event_type, klass, method_type, method_name, data )
      #   @abstract
      #   Add event to profile report.
      #   @param event_type [:started, :finished] event type
      #   @param klass [Class] class where called method is placed
      #   @param method_type [:instance, :singleton] method type
      #   @param method_name [Symbol] name of the called method
      #   @param data [nil, Float] event data, time represented as
      #     a Float microseconds value.
      #
      # @!method to_s
      #   @abstract
      #   @return [String] human-readable representation.
      class Report
      end
    end
  end
end
