class BenchmarkCLI
  module Compare
    # '10 steps' comparison.
    class TenSteps < Base
      TITLE = '10 steps, each returns `true` or `{ step_name: true }`, no input'.freeze
      NAME = :ten_steps

      def report_class_call(benchmark, title, klass)
        benchmark.report title do
          klass.call
        end
      end

      def report_instance_call(benchmark, title, klass)
        instance = klass.new
        benchmark.report title do
          instance.call
        end
      end
    end
  end
end
