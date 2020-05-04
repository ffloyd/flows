require_relative 'profiler/report'
require_relative 'profiler/injector'
require_relative 'profiler/wrapper'

module Flows
  module Plugin
    # Allows to record execution count and time of particular method on class or singleton class.
    #
    # Recorded data can be displayed in a different ways.
    # See {Profiler::Report} implementations for possible options.
    #
    # To do a measurement you have call your classes inside {.profile} block.
    #
    # @note even without calling {.profile} using this module has some performance
    #   impact. Don't left this module used in production environments.
    #
    # @example
    #     class MyClass
    #       CallProfiler = Flows::Plugin::Profiler.for_method(:call)
    #       include CallProfiler
    #
    #       def call(a, b)
    #         # some work here
    #       end
    #     end
    #
    #     class AnotherClass
    #       CallProfiler = Flows::Plugin::Profiler.for_method(:perform)
    #       extend CallProfiler
    #
    #       def self.perform(x)
    #         MyClass.new.call(x, x)
    #       end
    #     end
    #
    #     last_result = Flows::Plugin::Profiler.profile do
    #       AnotherClass.perform(2)
    #       AnotherClass.perform(6)
    #     end
    #
    #     Profiler.last_report.to_a
    #     # => [
    #     #   [:started,  AnotherClass, :singleton, :perform, nil],
    #     #   [:started,  MyClass,      :instance,  :call,    nil],
    #     #   [:finished, MyClass,      :instance,  :call,    7.3],
    #     #   [:finished, AnotherClass, :singleton, :perform, 10.5],
    #     #   [:started,  AnotherClass, :singleton, :perform, nil],
    #     #   [:started,  MyClass,      :instance,  :call,    nil],
    #     #   [:finished, MyClass,      :instance,  :call,    8.8],
    #     #   [:finished, AnotherClass, :singleton, :perform, 14.2]
    #     # ]
    module Profiler
      THREAD_VAR_FLAG = :flows_profiler_flag
      THREAD_VAR_REPORT = :flows_profiler_report

      class << self
        # Generates profiler module for a particular method.
        #
        # Use `include` for instance methods and `extend` for singleton ones.
        #
        # @param method_name [Symbol] method to wrap with profiling.
        # @return [Module] module to include or extend.
        def for_method(method_name)
          Module.new.tap do |mod|
            injector_mod = Injector.make_module(method_name)
            mod.const_set(:Injector, injector_mod)
            mod.extend injector_mod
          end
        end

        # Profiles a block execution.
        #
        # @param report [Report, Symbol]
        #   desired {Report} to be used.
        #   In case of symbol `:some_name` the `Flows::Plugin::Profiler::Report::SomeName.new` will be used.
        # @yield code to profile
        # @return block result
        def profile(report = :raw)
          thread = Thread.current

          thread[THREAD_VAR_FLAG] = true
          thread[THREAD_VAR_REPORT] = make_report(report)

          yield
        ensure
          thread[THREAD_VAR_FLAG] = false
        end

        # Resets thread-local variables used for reporting.
        def reset
          thread = Thread.current
          thread[THREAD_VAR_FLAG] = false
          thread[THREAD_VAR_REPORT] = nil
        end

        # @return [Report, nil] last generated report if some.
        def last_report
          Thread.current[THREAD_VAR_REPORT]
        end

        private

        def make_report(report_or_sym)
          case report_or_sym
          when Report then report_or_sym
          when Symbol
            const_name = report_or_sym.to_s.split('_').map(&:capitalize).join
            Report.const_get(const_name).new
          end
        end
      end
    end
  end
end
