class BenchmarkCLI
  module Examples
    module APlusB
      class FlowsRailway < Flows::Railway
        step :calculation

        def calculation(a:, b:)
          ok(sum: a + b)
        end
      end
    end
  end
end
