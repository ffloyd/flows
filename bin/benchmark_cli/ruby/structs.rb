require 'ostruct'

class BenchmarkCLI
  module Ruby
    class Structs
      include Helpers

      def call
        header 'Creates a struct with 3 random number fields and calculates the sum of the fields'

        Benchmark.ips do |benchmark|
          benchmark.config(stats: :bootstrap, confidence: 95)

          run_benchmarks(benchmark)

          benchmark.compare!
        end
      end

      RubyStruct = Struct.new(:a, :b, :c, keyword_init: true)

      class CustomStruct
        attr_reader :a, :b, :c

        def initialize(a:, b:, c:) # rubocop:disable Naming/MethodParameterName
          @a = a
          @b = b
          @c = c
        end
      end

      private

      def run_benchmarks(benchmark)
        report_hash(benchmark)
        report_ruby_struct(benchmark)
        report_custom_class(benchmark)
        report_ostruct(benchmark)
      end

      def report_hash(benchmark)
        benchmark.report 'Hash' do
          hash = {
            a: rand(10),
            b: rand(20),
            c: rand(30)
          }

          hash[:a] + hash[:b] + hash[:c]
        end
      end

      def report_ruby_struct(benchmark)
        benchmark.report 'Ruby Struct' do
          rstruct = RubyStruct.new(
            a: rand(10),
            b: rand(20),
            c: rand(30)
          )

          rstruct.a + rstruct.b + rstruct.c
        end
      end

      def report_custom_class(benchmark)
        benchmark.report 'Custom Class' do
          custom_struct = CustomStruct.new(
            a: rand(10),
            b: rand(10),
            c: rand(10)
          )

          custom_struct.a + custom_struct.b + custom_struct.c
        end
      end

      def report_ostruct(benchmark)
        benchmark.report 'Open Struct' do
          ostruct = OpenStruct.new( # rubocop:disable Style/OpenStructUse
            a: rand(10),
            b: rand(10),
            c: rand(10)
          )

          ostruct.a + ostruct.b + ostruct.c
        end
      end
    end
  end
end
