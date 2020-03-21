module Flows
  class Result
    # Do-notation for Result Objects
    module Do
      MOD_VAR_NAME = :@flows_result_module_for_do

      # Utility functions for Flows::Result::Do.
      #
      # Isolated location prevents polluting user classes with unnecessary methods.
      module Utils
        class << self
          def fetch_and_prepend_module(mod)
            module_for_do = mod.instance_variable_get(MOD_VAR_NAME)
            mod.prepend(module_for_do)
            module_for_do
          end

          # :reek:TooManyStatements: - allowed because we have no choice here
          # :reek:NestedIterators - allowed here because here are no iterators
          def define_wrapper(mod, method_name) # rubocop:disable Metrics/MethodLength
            mod.define_method(method_name) do |*args|
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
      end

      def self.extended(mod)
        ::Flows::Ext::InheritableSingletonVars::IsolationStrategy.call(
          mod,
          MOD_VAR_NAME => -> { Module.new }
        )
      end

      def do_for(method_name)
        prepended_mod = Utils.fetch_and_prepend_module(self)

        Utils.define_wrapper(prepended_mod, method_name)
      end
    end
  end
end
