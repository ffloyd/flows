module Flows
  module Ext
    # Helpers to build singleton-level attrs with support of inheritance.
    module InheritableAttrs
      class << self
        DUP_STRATEGY_WATCH_LIST_VAR_NAME = :@inheritable_vars_with_dup

        def dup_strategy(mod, attrs_with_default = {})
          init_variables_with_default_values(mod, attrs_with_default)

          var_names = attrs_with_default.keys.map(&:to_sym)
          add_variables_to_watch_list(mod, var_names, DUP_STRATEGY_WATCH_LIST_VAR_NAME)

          inject_inheritance_hook_for_dup_strategy(mod)
        end

        private

        def init_variables_with_default_values(mod, attrs_with_default)
          attrs_with_default.each do |name, default_value|
            mod.instance_variable_set(name, default_value)
          end
        end

        def add_variables_to_watch_list(mod, var_names, list_var_name)
          watch_list = mod.instance_variable_get(list_var_name) || []
          watch_list.concat(var_names)
          mod.instance_variable_set(list_var_name, watch_list)
        end

        def inject_inheritance_hook_for_dup_strategy(mod)
          mod.class_exec do
            def self.inherited(child_class)
              watch_list = instance_variable_get(DUP_STRATEGY_WATCH_LIST_VAR_NAME)
              child_class.instance_variable_set(DUP_STRATEGY_WATCH_LIST_VAR_NAME, watch_list.dup)

              watch_list.each do |name|
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
