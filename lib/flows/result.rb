module Flows
  # Result object with context
  class Result
    attr_reader :status, :meta

    def initialize(**)
      raise 'Use Flows::Result::Ok or Flows::Result::Err for build result objects'
    end
  end
end

require_relative 'result/errors'
require_relative 'result/ok'
require_relative 'result/err'
require_relative 'result/helpers'
