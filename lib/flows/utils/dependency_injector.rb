require_relative 'inheritable_singleton_vars'
require_relative 'prepend_to_class'

require_relative 'dependency_injector/errors'
require_relative 'dependency_injector/dependency'
require_relative 'dependency_injector/dependency_definition'
require_relative 'dependency_injector/dependency_list'

module Flows
  module Utils
    # Allows to inject dependencies on the initialization step.
    #
    # After including this module you inject dependencies by providing `:dependencies` key
    # to your initializer:
    #
    #     x = MyClass.new(dependencies: { my_dep: -> { 'Hi' } })
    #     x.my_dep
    #     # => 'Hi'
    #
    # Keys are dependency names. Dependency will be injected as
    # a public method with dependency name. Values are dependencies itself.
    #
    # You can also require some dependencies to be present.
    # If required dependency is missed - {MissingDependencyError} will be raised.
    #
    # If an optional dependency has no default - {MissingDependencyDefaultError} will be raised.
    #
    # For an optional dependency default value must be provided.
    #
    # You can provide a type for the dependency.
    # Type check uses case equality (`===`).
    # So, it works like Ruby's `case`.
    # In case of type mismatch {UnexpectedDependencyTypeError} will be raised.
    #
    #     dependency :name, type: String # name should be a string
    #
    #     # by the way, you can use lambdas like in Ruby's `case`
    #     dependency :age, type: ->(x) { x.is_a?(Number) && x > 0 && x < 100 }
    #
    # If you're trying to inject undeclared dependency - {UnexpectedDependencyError} will be raised.
    #
    # Inheritance is supported and dependency definitions will be inherited into child classes.
    #
    # @example
    #
    #     class MyClass
    #       include Flows::Utils::DepencyInjector
    #
    #       dependency :logger, required: true
    #       dependency :name, default: 'Boris', type: String # by default dependency is optional.
    #
    #       attr_reader :data
    #
    #       def initializer(data)
    #         @data = data
    #       end
    #
    #       def log_the_name
    #         logger.call(name)
    #       end
    #     end
    #
    #     class Logger
    #       def self.call(msg)
    #         puts msg
    #       end
    #     end
    #
    #     x = MyClass.new('DATA', dependencies: {
    #       logger: Logger
    #     })
    #
    #     x.data
    #     # => 'DATA'
    #
    #     x.name
    #     # => 'Boris'
    #
    #     x.logger.call('Hello')
    #     # prints 'Hello'
    #
    #     x.log_the_name
    #     # prints 'Boris'
    module DependencyInjector
      # Placeholder for empty type. We cannot use `nil` because value can be `nil`.
      NO_TYPE = :__no_type__

      # Placeholder for empty default. We cannot use `nil` because value can be `nil`.
      NO_DEFAULT = :__no_default__

      # Placeholder for empty value. We cannot use `nil` because value can be `nil`.
      NO_VALUE = :__no_value__

      Flows::Utils::InheritableSingletonVars::DupStrategy.call(
        self,
        '@dependencies' => {}
      )

      # @api private
      module DSL
        attr_reader :dependencies

        # `:reek:BooleanParameter` disabled here because it's not applicable for DSLs
        def dependency(name, required: false, default: NO_DEFAULT, type: NO_TYPE)
          dependencies[name] = DependencyDefinition.new(
            required: required,
            default: default,
            type: type
          )
        end
      end

      # @api private
      #
      # `:reek:UtilityFunction` and `:reek:FeatureEnvy` are disabled here because Reek does not
      # know about inheritance callback stuff.
      module InheritanceCallback
        def included(mod)
          mod.extend(DSL)

          mod.singleton_class.prepend(InheritanceCallback) if mod.class == Module

          super
        end

        def extended(mod)
          mod.extend(DSL)

          mod.singleton_class.prepend(InheritanceCallback) if mod.class == Module

          super
        end
      end

      singleton_class.prepend InheritanceCallback

      # @api private
      module InitializePatch
        def initialize(*args, **kwargs, &block)
          DependencyList.new(
            definitions: self.class.dependencies,
            provided_values: kwargs[:dependencies].dup || {}
          ).inject_to(self)

          filtered_kwargs = kwargs.reject { |key, _| key == :dependencies }

          if filtered_kwargs.empty? # https://bugs.ruby-lang.org/issues/14415
            super(*args, &block)
          else
            super(*args, **filtered_kwargs, &block)
          end
        end
      end

      Flows::Utils::PrependToClass.call(self, InitializePatch)
    end
  end
end
