module Flows
  class Result
    # Shortcuts for building result objects
    module Helpers
      private

      def ok(status = :success, **data)
        Flows::Result::Success.new(data, status: status)
      end

      def err(status = :failure, **data)
        Flows::Result::Failure.new(data, status: status)
      end

      def match_ok(status = nil)
        if status
          lambda do |result|
            result.is_a?(Flows::Result::Success) &&
              result.status == status
          end
        else
          ->(result) { result.is_a?(Flows::Result::Success) }
        end
      end

      def match_err(status = nil)
        if status
          lambda do |result|
            result.is_a?(Flows::Result::Failure) &&
              result.status == status
          end
        else
          ->(result) { result.is_a?(Flows::Result::Failure) }
        end
      end
    end
  end
end
