module Flows
  module Plugin
    module OutputContract
      # Base error class for output contract errors.
      class Error < StandardError; end

      # Raised when no single contract for successful results is defined
      class NoContractError < Error; end

      # Raised when result's data violates contract
      class ContractError < Error; end

      # Raised when no contract found for result
      class StatusError < Error; end

      # Raised when not a result object returned
      class ResultTypeError < Error; end
    end
  end
end
