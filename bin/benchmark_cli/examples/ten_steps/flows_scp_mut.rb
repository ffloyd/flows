class BenchmarkCLI
  module Examples
    module TenSteps
      class FlowsSCPMut < Flows::SharedContextPipeline
        mut_step :s1
        mut_step :s2
        mut_step :s3
        mut_step :s4
        mut_step :s5
        mut_step :s6
        mut_step :s7
        mut_step :s8
        mut_step :s9
        mut_step :s10

        def s1(ctx)
          ctx[:s1] = true
        end

        def s2(ctx)
          ctx[:s2] = true
        end

        def s3(ctx)
          ctx[:s3] = true
        end

        def s4(ctx)
          ctx[:s4] = true
        end

        def s5(ctx)
          ctx[:s5] = true
        end

        def s6(ctx)
          ctx[:s6] = true
        end

        def s7(ctx)
          ctx[:s7] = true
        end

        def s8(ctx)
          ctx[:s8] = true
        end

        def s9(ctx)
          ctx[:s9] = true
        end

        def s10(ctx)
          ctx[:s10] = true
        end
      end
    end
  end
end
