class BenchmarkCLI
  module Compare
    # Comparison benchmarks command.
    class Command
      include Helpers
      include Flows::Result::Helpers
      extend Flows::Result::Do

      def initialize(benchmarks, modes, implementations)
        @benchmarks = benchmarks.map(&:to_sym)
        @implementations = implementations.map(&:to_sym)
        @modes = modes.map(&:to_sym)
      end

      do_notation(:call)
      def call
        yield validate_benchmarks
        yield validate_modes
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

      def validate_modes
        @modes.each do |mode|
          return err_data("Unexpected mode: #{mode}") unless MODES.key?(mode)
        end

        ok
      end

      def run
        @benchmarks.each do |name|
          BENCHMARKS[name].new(@implementations, @modes).call
        end
      end
    end
  end
end
