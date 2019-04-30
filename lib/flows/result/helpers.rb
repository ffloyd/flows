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
    end
  end
end
