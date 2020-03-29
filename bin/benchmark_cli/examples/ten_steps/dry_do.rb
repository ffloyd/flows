require 'dry/monads'
require 'dry/monads/do'

class BenchmarkCLI
  module Examples
    module TenSteps
      class DryDo
        include Dry::Monads[:result]

        include Dry::Monads::Do.for(:call)
        def call
          x1 = yield s1(:s1)
          x2 = yield s2(:s2)
          x3 = yield s3(:s3)
          x4 = yield s4(:s4)
          x5 = yield s5(:s5)
          x6 = yield s6(:s6)
          x7 = yield s7(:s7)
          x8 = yield s8(:s8)
          x9 = yield s9(:s9)
          x10 = yield s10(:s10)

          Success(x10)
        end

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
