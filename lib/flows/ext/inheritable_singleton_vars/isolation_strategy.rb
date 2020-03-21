module Flows
  module Ext
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

        class << self
          # Applies behaviour and defaults for singleton variables.
          #
          # @note Variable names should look like `:@var` or `'@var'`.
          #
          # @param klass [Class] target class.
          # @param attrs_with_default [Hash<Symbol, String => Proc>] keys are variable names,
          #   values are procs or lambdas which return default values.
          #
          # @example
          #   class MyClass
          #     Flows::Ext::InheritableSingletonVars::IsolationStrategy.call(
          #       self,
          #       :@my_list => -> { [] }
          #     )
          #   end
          def call(mod, attrs_with_default = {})
            init_variables_with_default_values(mod, attrs_with_default)

            var_defaults = attrs_with_default
            add_variables_to_store(mod, var_defaults)

            inject_inheritance_hook(mod)
          end

          private

          def init_variables_with_default_values(mod, attrs_with_default)
            attrs_with_default.each do |name, default_value_proc|
              mod.instance_variable_set(name, default_value_proc.call)
            end
          end

          def add_variables_to_store(mod, var_defaults)
            store = mod.instance_variable_get(VAR_MAP_VAR_NAME) || {}
            next_store = store.merge(var_defaults)

            mod.instance_variable_set(VAR_MAP_VAR_NAME, next_store)
          end

          def inject_inheritance_hook(mod)
            mod.class_exec do
              def self.inherited(child_class)
                new_var_map = instance_variable_get(VAR_MAP_VAR_NAME).transform_values(&:dup)

                child_class.instance_variable_set(VAR_MAP_VAR_NAME, new_var_map)

                new_var_map.each do |name, default_value_proc|
                  child_class.instance_variable_set(name, default_value_proc.call)
                end

                super
              end
            end
          end
        end
      end
    end
  end
end
