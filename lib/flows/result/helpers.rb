module Flows
  class Result
    # Shortcuts for building and matching result objects.
    #
    # `:reek:UtilityFunction` and `:reek:FeatureEnvy` checks should be disabled here
    # because this module is intended to contain private utility methods only.
    #
    # This module defines the following private methods:
    #
    # * `ok(status = :ok, **data)` - for building successful results.
    # * `err(status = :err, **data)` - for building failure results.
    # * `match_ok(status = nil)` - for case matching against successful results.
    # * `match_err(status = nil)` - for case matching against failure results.
    #
    # @see Flows::Result usage examples provided here
    module Helpers
      private

      def ok(status = :ok, **data)
        Flows::Result::Ok.new(data, status: status)
      end

      def err(status = :err, **data)
        Flows::Result::Err.new(data, status: status)
      end

      def match_ok(status = nil)
        if status
          lambda do |result|
            result.is_a?(Flows::Result::Ok) &&
              result.status == status
          end
        else
          Flows::Result::Ok
        end
      end

      def match_err(status = nil)
        if status
          lambda do |result|
            result.is_a?(Flows::Result::Err) &&
              result.status == status
          end
        else
          Flows::Result::Err
        end
      end
    end
  end
end
