module Flows
  module Plugin
    module Profiler
      # @api private
      module Wrapper
        class << self
          def make_instance_wrapper(method_name) # rubocop:disable Metrics/MethodLength
            Module.new.tap do |mod|
              mod.define_method(method_name) do |*args, **kwargs, &block| # rubocop:disable Metrics/MethodLength
                thread = Thread.current
                klass = self.class

                return super(*args, **kwargs, &block) unless thread[THREAD_VAR_FLAG]

                report = thread[THREAD_VAR_REPORT]
                report.add(:started, klass, :instance, method_name, nil)

                before = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_microsecond)
                super(*args, **kwargs, &block)
              ensure
                if before
                  after = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_microsecond)
                  report.add(:finished, klass, :instance, method_name, after - before)
                end
              end
            end
          end

          def make_singleton_wrapper(method_name) # rubocop:disable Metrics/MethodLength
            Module.new.tap do |mod|
              mod.define_method(method_name) do |*args, **kwargs, &block| # rubocop:disable Metrics/MethodLength
                thread = Thread.current

                return super(*args, **kwargs, &block) unless thread[THREAD_VAR_FLAG]

                report = thread[THREAD_VAR_REPORT]
                report.add(:started, self, :singleton, method_name, nil)

                before = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_microsecond)
                super(*args, **kwargs, &block)
              ensure
                if before
                  after = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_microsecond)
                  report.add(:finished, self, :singleton, method_name, after - before)
                end
              end
            end
          end
        end
      end
    end
  end
end
