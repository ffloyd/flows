require 'trailblazer/operation'

class BenchmarkCLI
  module Examples
    module TenSteps
      class TB < Trailblazer::Operation
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

        def s1(opts, **)
          opts[:s1] = true
        end

        def s2(opts, s1:, **)
          opts[:s2] = true
        end

        def s3(opts, s2:, **)
          opts[:s3] = true
        end

        def s4(opts, s3:, **)
          opts[:s4] = true
        end

        def s5(opts, s4:, **)
          opts[:s5] = true
        end

        def s6(opts, s5:, **)
          opts[:s6] = true
        end

        def s7(opts, s6:, **)
          opts[:s7] = true
        end

        def s8(opts, s7:, **)
          opts[:s8] = true
        end

        def s9(opts, s8:, **)
          opts[:s9] = true
        end

        def s10(opts, s9:, **)
          opts[:s10] = true
        end
      end
    end
  end
end
