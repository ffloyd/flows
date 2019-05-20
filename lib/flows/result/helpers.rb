module Flows
  class Result
    # Shortcuts for building result objects
    module Helpers
      private

      def ok(status = :success, **data)
        Flows::Result::Ok.new(data, status: status)
      end

      def err(status = :failure, **data)
        Flows::Result::Err.new(data, status: status)
      end

      def match_ok(status = nil)
        if status
          lambda do |result|
            result.is_a?(Flows::Result::Ok) &&
              result.status == status
          end
        else
          ->(result) { result.is_a?(Flows::Result::Ok) }
        end
      end

      def match_err(status = nil)
        if status
          lambda do |result|
            result.is_a?(Flows::Result::Err) &&
              result.status == status
          end
        else
          ->(result) { result.is_a?(Flows::Result::Err) }
        end
      end
    end
  end
end
