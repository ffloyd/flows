module Flows
  module Util
    module InheritableSingletonVars
      # Strategy which uses procs to generate initial values in target class and children.
      #
      # This strategy designed to make fully isolated singleton variables between classes.
      #
      # Can be applied several times to the same class.
      #
      # Can be applied in the middle of inheritance chain.
      #
      # @see InheritableSingletonVars the parent module's documentation describes the problem this module solves.
      #
      # @since 0.4.0
      module IsolationStrategy
        VAR_MAP_VAR_NAME = :@inheritable_vars_with_isolation

        # @api private
        module Migrator
          def self.call(from, to)
            parent_var_map = from.instance_variable_get(VAR_MAP_VAR_NAME)
            child_var_map = to.instance_variable_get(VAR_MAP_VAR_NAME) || {}

            to.instance_variable_set(VAR_MAP_VAR_NAME, child_var_map.merge(parent_var_map))

            parent_var_map.each do |name, value_proc|
              to.instance_variable_set(name, value_proc.call)
            end
          end
        end

        # @api private
        module Injector
          def included(mod)
            Migrator.call(self, mod)
            mod.singleton_class.prepend Injector

            super
          end

          def extended(mod)
            Migrator.call(self, mod)
            mod.singleton_class.prepend Injector

            super
          end

          def inherited(mod)
            Migrator.call(self, mod)
            mod.singleton_class.prepend Injector

            super
          end
        end

        class << self
          # Applies behaviour and defaults for singleton variables.
          #
          # @example
          #   class MyClass
          #     SingletonVarsSetup = Flows::Util::InheritableSingletonVars::IsolationStrategy.make_module(
          #       :@my_list => -> { [] }
          #     )
          #
          #     include SingletonVarsSetup
          #   end
          #
          # @note Variable names should look like `:@var` or `'@var'`.
          #
          # @param vars_with_default [Hash<Symbol, String => Proc>] keys are variable names,
          #   values are procs or lambdas which return default values.
          def make_module(vars_with_default = {})
            Module.new.tap do |mod|
              mod.instance_variable_set(VAR_MAP_VAR_NAME, vars_with_default.dup)
              init_vars(mod, vars_with_default)
              mod.extend Injector
            end
          end

          private

          def init_vars(mod, vars_with_default)
            vars_with_default.each do |name, value_proc|
              mod.instance_variable_set(name, value_proc.call)
            end
          end
        end
      end
    end
  end
end
