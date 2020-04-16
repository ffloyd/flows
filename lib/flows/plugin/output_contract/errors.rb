module Flows
  module Plugin
    module OutputContract
      # Base error class for output contract errors.
      class Error < StandardError; end

      # Raised when no single contract for successful results is defined
      class NoContractError < Error
        def initialize(klass)
          @klass = klass
        end

        def message
          "No single success contract defined for #{@klass}"
        end
      end

      # Raised when result's data violates contract
      class ContractError < Error
        def initialize(klass, result, error)
          @klass = klass
          @result = result
          @error = error
        end

        def message
          shifted_error = @error.split("\n").map { |str| '  ' + str }.join("\n")

          "Output contract for #{@klass} is violated.\n" \
          "Result:\n" \
          "  `#{@result.inspect}`\n" \
          "Contract Error:\n" \
          "#{shifted_error}"
        end
      end

      # Raised when no contract found for result
      class StatusError < Error
        def initialize(klass, result, allowed_statuses)
          @klass = klass
          @result = result
          @allowed_statuses = allowed_statuses
        end

        def message
          allowed_statuses_str = @allowed_statuses.map { |st| "`#{st.inspect}`" }.join(', ')

          "Output contract for #{@klass} is violated.\n" \
          "Result:\n" \
          "  `#{@result.inspect}`\n" \
          "Contract Error:\n" \
          "  has unexpected status `#{@result.status.inspect}`\n" \
          "  allowed statuses for `#{@result.class}` are: #{allowed_statuses_str}"
        end
      end

      # Raised when not a result object returned
      class ResultTypeError < Error
        def initialize(klass, result)
          @klass = klass
          @result = result
        end

        def message
          "Output contract for #{@klass} is violated.\n" \
          "Result:\n" \
          "  `#{@result.inspect}`\n" \
          "Contract Error:\n" \
          '  result must be instance of `Flows::Result`'
        end
      end
    end
  end
end
