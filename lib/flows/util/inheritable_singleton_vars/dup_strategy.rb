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
        module InheritanceCallback
          def inherited(child_class)
            DupStrategy.migrate(self, child_class)

            super
          end

          def included(child_mod)
            DupStrategy.migrate(self, child_mod)

            child_mod.singleton_class.prepend(InheritanceCallback)

            super
          end

          def extended(child_mod)
            DupStrategy.migrate(self, child_mod)

            child_mod.singleton_class.prepend(InheritanceCallback)

            super
          end
        end

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
          #     Flows::Util::InheritableSingletonVars::DupStrategy.call(
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

          # Moves variables between modules
          #
          # @api private
          def migrate(from_mod, to_mod)
            var_list = from_mod.instance_variable_get(VAR_LIST_VAR_NAME)
            to_mod.instance_variable_set(VAR_LIST_VAR_NAME, var_list.dup)

            var_list.each do |name|
              to_mod.instance_variable_set(name, from_mod.instance_variable_get(name).dup)
            end
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
            singleton = klass.singleton_class
            singleton.prepend(InheritanceCallback) unless singleton.is_a?(InheritanceCallback)
          end
        end
      end
    end
  end
end
