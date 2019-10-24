module Flows
  class Result
    # Do-notation for Result Objects
    module Do
      # DSL for Do-notation
      module DSL
        def do_for(method_name) # rubocop:disable Metrics/MethodLength
          @flows_result_do_module.define_method(method_name) do |*args|
            super(*args) do |*fields, result|
              case result
              when Flows::Result::Ok
                data = result.unwrap
                fields.any? ? data.values_at(*fields) : data
              when Flows::Result::Err then return result
              else raise "Unexpected result: #{result.inspect}. Should be a Flows::Result"
              end
            end
          end
        end
      end

      def self.included(mod)
        patch_mod = Module.new

        mod.instance_variable_set(:@flows_result_do_module, patch_mod)
        mod.prepend(patch_mod)
        mod.extend(DSL)
      end
    end
  end
end
