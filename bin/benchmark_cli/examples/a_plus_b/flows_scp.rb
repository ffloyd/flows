class BenchmarkCLI
  module Examples
    module APlusB
      class FlowsSCP < Flows::SharedContextPipeline
        step :calculation

        def calculation(a:, b:)
          ok(sum: a + b)
        end
      end
    end
  end
end
