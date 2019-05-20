module Flows
  # Result object with context
  class Result
    attr_reader :status, :meta

    def initialize(data, status:, meta: {})
      @data = data
      @status = status
      @meta = meta

      raise 'Use Flows::Result::Ok or Flows::Result::Err for build result objects' if self.class == Result
    end
  end
end

require_relative 'result/ok'
require_relative 'result/err'
require_relative 'result/helpers'
