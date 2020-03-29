class BenchmarkCLI
  module Compare
    # 'A + B' comparison.
    class APlusB < Base
      TITLE = 'A + B: one step implementation, input provided as kwargs'.freeze
      NAME = :a_plus_b

      def report_class_call(benchmark, title, klass)
        benchmark.report title do
          klass.call(a: 100, b: 200)
        end
      end

      def report_instance_call(benchmark, title, klass)
        instance = klass.new
        benchmark.report title do
          instance.call(a: 100, b: 200)
        end
      end
    end
  end
end
