class BenchmarkCLI
  module Examples
    module TenSteps
      class FlowsDo
        include Flows::Result::Helpers

        extend Flows::Result::Do

        do_notation(:call)
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

          ok
        end

        private

        def s1(_sym)
          ok_data(true)
        end

        def s2(_sym)
          ok_data(true)
        end

        def s3(_sym)
          ok_data(true)
        end

        def s4(_sym)
          ok_data(true)
        end

        def s5(_sym)
          ok_data(true)
        end

        def s6(_sym)
          ok_data(true)
        end

        def s7(_sym)
          ok_data(true)
        end

        def s8(_sym)
          ok_data(true)
        end

        def s9(_sym)
          ok_data(true)
        end

        def s10(_sym)
          ok_data(true)
        end
      end
    end
  end
end
