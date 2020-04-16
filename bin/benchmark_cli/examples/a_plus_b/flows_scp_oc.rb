class BenchmarkCLI
  module Examples
    module APlusB
      class FlowsSCPOC < Flows::SharedContextPipeline
        include Flows::Plugin::OutputContract

        step :calculation

        success_with :ok do
          hash_of(
            sum: Integer
          )
        end

        def calculation(a:, b:)
          ok(sum: a + b)
        end
      end
    end
  end
end
