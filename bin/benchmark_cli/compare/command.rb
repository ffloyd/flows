class BenchmarkCLI
  module Compare
    # Comparison benchmarks command.
    class Command
      include Helpers
      include Flows::Result::Helpers
      extend Flows::Result::Do

      def initialize(benchmarks, implementations)
        @benchmarks = benchmarks.map(&:to_sym)
        @implementations = implementations.map(&:to_sym)
      end

      do_notation(:call)
      def call
        yield validate_benchmarks
        yield validate_implementations

        run
      end

      private

      def validate_benchmarks
        @benchmarks.each do |benchmark|
          return err_data("Unexpected benchmark: #{benchmark}") unless BENCHMARKS.key?(benchmark)
        end

        ok
      end

      def validate_implementations
        @implementations.each do |impl|
          return err_data("Unexpected implementation: #{impl}") unless IMPLEMENTATIONS.key?(impl)
        end

        ok
      end

      def run
        @benchmarks.each do |name|
          BENCHMARKS[name].new(@implementations).call
        end
      end
    end
  end
end
