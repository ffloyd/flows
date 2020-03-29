class BenchmarkCLI
  module Ruby
    class Command
      include Flows::Result::Helpers
      extend Flows::Result::Do

      attr_reader :benchmarks

      def initialize(benchmarks)
        @benchmarks = benchmarks.map(&:to_sym)
      end

      do_notation(:call)
      def call
        yield validate
        run
      end

      private

      def validate
        benchmarks.each do |benchmark|
          return err_data("Unexpected benchmark: #{benchmark}") unless BENCHMARKS.key?(benchmark)
        end

        ok
      end

      def run
        benchmarks.each do |benchmark|
          BENCHMARKS[benchmark].new.call
        end

        ok
      end
    end
  end
end
