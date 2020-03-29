class BenchmarkCLI
  module Ruby
    class MethodExec
      include Helpers

      def initialize
        @instance = OneMethod.new
        @method_obj = @instance.method(:meth)
        @lambda = -> { :ok }
      end

      def call
        header 'Different method execution ways'

        Benchmark.ips do |benchmark|
          benchmark.config(stats: :bootstrap, confidence: 95)

          run_benchmarks(benchmark)

          benchmark.compare!
        end
      end

      class OneMethod
        def meth
          :ok
        end
      end

      private

      def run_benchmarks(benchmark)
        report_method_call(benchmark)
        report_public_send(benchmark)
        report_send(benchmark)
        report_method_object(benchmark)
        report_lambda_call(benchmark)
      end

      def report_method_call(benchmark)
        benchmark.report 'Call a method on an instance' do
          @instance.meth
        end
      end

      def report_public_send(benchmark)
        benchmark.report 'Call a method using #public_send' do
          @instance.public_send(:meth)
        end
      end

      def report_send(benchmark)
        benchmark.report 'Call a method using #send' do
          @instance.send(:meth)
        end
      end

      def report_method_object(benchmark)
        benchmark.report 'Execute an extracted via #method(name) method object' do
          @method_obj.call
        end
      end

      def report_lambda_call(benchmark)
        benchmark.report 'Execute a simple lambda' do
          @lambda.call
        end
      end
    end
  end
end
