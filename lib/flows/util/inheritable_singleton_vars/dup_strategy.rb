module Flows
  module Util
    module InheritableSingletonVars
      # Strategy which uses `#dup` to copy variables to a child class.
      #
      # Can be applied several times to the same class.
      #
      # Can be applied in the middle of inheritance chain.
      #
      # When your value is a custom class you may need to adjust `#dup` behaviour.
      # It can be done using `initialize_dup` method.
      # Unfortunately it's not documented well in the standard library.
      # So, [this will help you](https://blog.appsignal.com/2019/02/26/diving-into-dup-and-clone.html).
      #
      # @note If you change variables in a parent class after a child being defined
      #   it will have no effect on a child. Remember this when working in environments
      #   with tricky or experimental autoload mechanism.
      #
      # @see InheritableSingletonVars the parent module's documentation describes the problem this module solves.
      #
      # @since 0.4.0
      module DupStrategy
        VAR_LIST_VAR_NAME = :@inheritable_vars_with_dup

        # @api private
        module Migrator
          # :reek:TooManyStatements is allowed here because it's impossible to split to smaller methods
          def self.call(src_mod, dst_mod)
            parent_var_list = src_mod.instance_variable_get(VAR_LIST_VAR_NAME)
            child_var_list = dst_mod.instance_variable_get(VAR_LIST_VAR_NAME) || []
            skip_list = parent_var_list & child_var_list

            dst_mod.instance_variable_set(VAR_LIST_VAR_NAME, (child_var_list + parent_var_list).uniq)

            (parent_var_list - skip_list).each do |name|
              dst_mod.instance_variable_set(name, src_mod.instance_variable_get(name).dup)
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
          # Generates a module which applies behaviour and defaults for singleton variables.
          #
          # @example
          #   class MyClass
          #     SingletonVarsSetup = Flows::Util::InheritableSingletonVars::DupStrategy.make_module(
          #       :@my_list => []
          #     )
          #
          #     include SingletonVarsSetup
          #   end
          #
          # @note Variable names should look like `:@var` or `'@var'`.
          #
          # @param vars_with_default [Hash<Symbol, String => Object>] keys are variable names,
          #   values are default values.
          def make_module(vars_with_default = {})
            Module.new.tap do |mod|
              mod.instance_variable_set(VAR_LIST_VAR_NAME, vars_with_default.keys.map(&:to_sym))
              init_vars(mod, vars_with_default)
              mod.extend Injector
            end
          end

          private

          def init_vars(mod, vars_with_default)
            vars_with_default.each do |name, value|
              mod.instance_variable_set(name, value)
            end
          end
        end
      end
    end
  end
end
