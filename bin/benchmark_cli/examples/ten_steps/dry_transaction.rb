require 'dry/transaction'

class BenchmarkCLI
  module Examples
    module TenSteps
      class DryTransaction
        include Dry::Transaction

        step :s1
        step :s2
        step :s3
        step :s4
        step :s5
        step :s6
        step :s7
        step :s8
        step :s9
        step :s10

        private

        def s1(_x)
          Success(true)
        end

        def s2(_x)
          Success(true)
        end

        def s3(_x)
          Success(true)
        end

        def s4(_x)
          Success(true)
        end

        def s5(_x)
          Success(true)
        end

        def s6(_x)
          Success(true)
        end

        def s7(_x)
          Success(true)
        end

        def s8(_x)
          Success(true)
        end

        def s9(_x)
          Success(true)
        end

        def s10(_x)
          Success(true)
        end
      end
    end
  end
end
