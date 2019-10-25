module Flows
  module Ext
    module InheritableAttrs
      # Strategy which uses #dup to copy variables to a child class.
      module DupStrategy
        VAR_LIST_VAR_NAME = :@inheritable_vars_with_dup

        class << self
          def call(mod, attrs_with_default = {})
            init_variables_with_default_values(mod, attrs_with_default)

            var_names = attrs_with_default.keys.map(&:to_sym)
            add_var_list(mod, var_names)

            inject_inheritance_hook(mod)
          end

          private

          def init_variables_with_default_values(mod, attrs_with_default)
            attrs_with_default.each do |name, default_value|
              mod.instance_variable_set(name, default_value)
            end
          end

          def add_var_list(mod, var_names)
            watch_list = mod.instance_variable_get(VAR_LIST_VAR_NAME) || []
            watch_list.concat(var_names)
            mod.instance_variable_set(VAR_LIST_VAR_NAME, watch_list)
          end

          def inject_inheritance_hook(mod)
            mod.class_exec do
              def self.inherited(child_class)
                var_list = instance_variable_get(VAR_LIST_VAR_NAME)
                child_class.instance_variable_set(VAR_LIST_VAR_NAME, var_list.dup)

                var_list.each do |name|
                  child_class.instance_variable_set(name, instance_variable_get(name).dup)
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
