module Flows
  module Plugin
    # Class extension to define Java/C#-like interfaces in Ruby.
    #
    # On target class initialization will check defined methods for existance.
    #
    # **Currently interface composition is not supported.** You cannot define
    # 2 interface modules and include it into one class.
    #
    # @example Simple interface
    #   class MyAction
    #     extend Flows::Plugin::Interface
    #
    #     defmethod :perform
    #   end
    #
    #   class InvalidAction < MyAction; end
    #   InvalidAction.new
    #   # will raise an error
    #
    #   class ValidAction < MyAction
    #     def perfrom
    #       puts 'Hello!'
    #     end
    #   end
    #   ValidAction.new.perform
    #   # => Hello!
    #
    # @example Interface as module
    #   module MyBehavior
    #     extend Flows::Plugin::Interface
    #
    #     defmethod :my_method
    #   end
    #
    #   class MyImplementation
    #     include MyBehaviour
    #
    #     def my_method; end
    #   end
    module Interface
      # Base error class for interface errors.
      class Error < ::Flows::Error; end

      # Raised when you're missed some dependency.
      class MissingMethodsError < Error
        def initialize(klass, names)
          @klass = klass
          @names = names
        end

        def message
          "Methods required by interface for #{@klass} are missing: #{@names.map(&:to_s).join(', ')}"
        end
      end

      SingletonVarsSetup = Flows::Util::InheritableSingletonVars::DupStrategy.make_module(
        '@interface_methods' => {}
      )

      include SingletonVarsSetup

      InitializePatch = Flows::Util::PrependToClass.make_module do
        def initialize(*)
          klass = self.class

          required_methods = klass.instance_variable_get(:@interface_methods).keys
          missing_methods = required_methods - methods

          raise MissingMethodsError.new(klass, missing_methods) if missing_methods.any?

          super
        end
      end

      include InitializePatch

      def defmethod(method_name)
        method_list = instance_variable_get(:@interface_methods)
        method_list[method_name.to_sym] = { required_by: self }
      end
    end
  end
end
