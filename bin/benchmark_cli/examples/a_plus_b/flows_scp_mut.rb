class BenchmarkCLI
  module Examples
    module APlusB
      class FlowsSCPMut < Flows::SharedContextPipeline
        mut_step :calculation

        def calculation(ctx)
          ctx[:cum] = ctx[:a] + ctx[:b]
        end
      end
    end
  end
end
