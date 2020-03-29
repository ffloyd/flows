class BenchmarkCLI
  module Examples
    module APlusB
      class FlowsDo
        include Flows::Result::Helpers

        extend Flows::Result::Do

        do_notation(:call)
        def call(a:, b:)
          ok_data(yield do_call(a, b))
        end

        private

        def do_call(a, b)
          ok_data(a + b)
        end
      end
    end
  end
end
