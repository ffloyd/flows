require 'dry/transaction'

class BenchmarkCLI
  module Examples
    module APlusB
      class DryTransaction
        include Dry::Transaction

        step :calculation

        def calculation(a:, b:)
          Success(a + b)
        end
      end
    end
  end
end
