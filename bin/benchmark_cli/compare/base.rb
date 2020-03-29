class BenchmarkCLI
  module Compare
    # @abstract
    #
    # Base class for comparison benchmarks.
    class Base
      include Helpers

      def initialize(implementations, modes)
        @implementations = implementations
        @modes = modes
      end

      def call
        header self.class::TITLE

        Benchmark.ips do |benchmark|
          benchmark.config(stats: :bootstrap, confidence: 95)

          report_implementations(benchmark)

          benchmark.compare!
        end
      end

      private

      def report_implementations(benchmark)
        @implementations.each do |implementation|
          report_implementation(benchmark, IMPLEMENTATIONS[implementation])
        end
      end

      def report_implementation(benchmark, cfg)
        @modes.each do |mode|
          next unless cfg[:modes].include?(mode)

          report_mode(benchmark, cfg, mode)
        end
      end

      def report_mode(benchmark, cfg, mode)
        title = "#{cfg[:title]} (#{MODES[mode]})"
        klass = cfg[:classes][self.class::NAME]

        case mode
        when :class_call then report_class_call(benchmark, title, klass)
        when :instance_call then report_instance_call(benchmark, title, klass)
        end
      end
    end
  end
end
