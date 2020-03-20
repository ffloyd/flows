module Flows
  module Ext
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
      # @see InheritableSingletonVars the parent module's documentation describes the problem this module solves.
      #
      # @since 0.4.0
      module DupStrategy
        VAR_LIST_VAR_NAME = :@inheritable_vars_with_dup

        class << self
          # Applies behaviour and defaults for singleton variables.
          #
          # @note Variable names should look like `:@var` or `'@var'`.
          #
          # @param klass [Class] target class.
          # @param attrs_with_default [Hash<Symbol, String => Object>] keys are variable names,
          #   values are default values.
          #
          # @example
          #   class MyClass
          #     Flows::Ext::InheritableSingletonVars::DupStrategy.call(
          #       self,
          #       :@my_list => []
          #     )
          #   end
          def call(klass, attrs_with_default = {})
            init_variables_with_default_values(klass, attrs_with_default)

            var_names = attrs_with_default.keys.map(&:to_sym)
            add_var_list(klass, var_names)

            inject_inheritance_hook(klass)
          end

          private

          def init_variables_with_default_values(klass, attrs_with_default)
            attrs_with_default.each do |name, default_value|
              klass.instance_variable_set(name, default_value)
            end
          end

          def add_var_list(klass, var_names)
            watch_list = klass.instance_variable_get(VAR_LIST_VAR_NAME) || []
            watch_list.concat(var_names)
            klass.instance_variable_set(VAR_LIST_VAR_NAME, watch_list)
          end

          def inject_inheritance_hook(klass)
            klass.class_exec do
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
