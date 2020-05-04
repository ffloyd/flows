module Flows
  module Plugin
    module Profiler
      # @api private
      module Wrapper
        class << self
          def make_module(klass, method_type, method_name) # rubocop:disable Metrics/MethodLength
            Module.new.tap do |mod|
              mod.define_method(method_name) do |*args, &block|
                thread = Thread.current

                return super(*args, &block) unless thread[THREAD_VAR_FLAG]

                report = thread[THREAD_VAR_REPORT]
                report.add(:started, klass, method_type, method_name, nil)

                before = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_microsecond)
                super(*args, &block)
              ensure
                after = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_microsecond)
                report.add(:finished, klass, method_type, method_name, after - before)
              end
            end
          end
        end
      end
    end
  end
end
