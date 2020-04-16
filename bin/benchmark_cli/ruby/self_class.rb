class BenchmarkCLI
  module Ruby
    class SelfClass
      include Helpers

      def call
        header 'Check if repeatative `self.class` impacts performance'

        Benchmark.ips do |benchmark|
          benchmark.config(stats: :bootstrap, confidence: 95)

          run_benchmarks(benchmark)

          benchmark.compare!
        end
      end

      private

      def run_benchmarks(benchmark)
        report_self_class(benchmark)
        report_klass(benchmark)
      end

      def report_self_class(benchmark)
        benchmark.report '[self.class, ... 10 times]' do
          self_class_10_times
        end
      end

      def self_class_10_times # rubocop:disable Metrics/MethodLength
        [
          self.class,
          self.class,
          self.class,
          self.class,
          self.class,
          self.class,
          self.class,
          self.class,
          self.class,
          self.class
        ]
      end

      def report_klass(benchmark)
        benchmark.report 'klass = self.class; [klass, ... 10 times]' do
          klass_10_times
        end
      end

      def klass_10_times # rubocop:disable Metrics/MethodLength
        klass = self.class
        [
          klass,
          klass,
          klass,
          klass,
          klass,
          klass,
          klass,
          klass,
          klass,
          klass
        ]
      end
    end
  end
end
