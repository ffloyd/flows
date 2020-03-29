require 'dry/monads'
require 'dry/monads/do'

class BenchmarkCLI
  module Examples
    module APlusB
      class DryDo
        include Dry::Monads[:result]

        include Dry::Monads::Do.for(:call)
        def call(a:, b:)
          Success(yield do_call(a, b))
        end

        private

        def do_call(a, b)
          Success(a + b)
        end
      end
    end
  end
end
