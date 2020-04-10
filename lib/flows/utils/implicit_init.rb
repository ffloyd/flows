module Flows
  module Utils
    # Class extension with method `MyClass.call` which works like `MyClass.new.call`.
    #
    # @note This module must be injected into target class using `extend`, not `include`.
    #
    # @note Class inheritance is supported: each child class will inherit behaviour, but not data.
    #
    # @example Extending a class
    #   class SomeClass
    #     extend Flows::Utils::ImplicitInit
    #
    #     def initialize(param: 'default')
    #       @param = param
    #     end
    #
    #     def call
    #       @param
    #     end
    #   end
    #
    #   SomeClass.call
    #   # => 'default'
    #
    #   SomeClass.default_instance.call
    #   # => 'default'
    # @since 0.4.0
    module ImplicitInit
      # Contains memoized instance of a host class or `nil`.
      attr_reader :default_instance

      # Creates an instance of a host class by calling `new` without arguments and
      # calls `#call` method on the instance with provided parameters and block.
      #
      # After first invocation the instance will be memoized in {.default_instance}.
      #
      # Child classes have separate default instances.
      def call(*args, **kwargs, &block)
        @default_instance ||= new

        default_instance.call(*args, **kwargs, &block)
      end
    end
  end
end
