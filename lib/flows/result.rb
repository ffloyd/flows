module Flows
  # Result object with context
  class Result
    attr_reader :status, :meta

    def initialize(data, status:, meta: {})
      @data = data
      @status = status
      @meta = meta

      raise 'Use Flows::Result::Success or Flows::Result::Failure for build result objects' if self.class == Result
    end
  end
end
