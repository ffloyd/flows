module Flows
  module Ext
    module InheritableAttrs
      # Strategy which uses #dup on initial default values to initialize child ones.
      module ReinitStrategy
        VAR_MAP_VAR_NAME = :@inheritable_vars_with_reinit

        class << self
          def call(mod, attrs_with_default = {})
            init_variables_with_default_values(mod, attrs_with_default)

            var_defaults = attrs_with_default.transform_values(&:dup)
            add_variables_to_store(mod, var_defaults)

            inject_inheritance_hook(mod)
          end

          private

          def init_variables_with_default_values(mod, attrs_with_default)
            attrs_with_default.each do |name, default_value|
              mod.instance_variable_set(name, default_value)
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

                new_var_map.each do |name, default_value|
                  child_class.instance_variable_set(name, default_value)
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
