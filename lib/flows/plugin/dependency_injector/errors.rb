module Flows
  module Plugin
    module DependencyInjector
      # Base error class for dependency injection errors.
      class Error < ::Flows::Error; end

      # Raised when you're missed some dependency.
      class MissingDependencyError < Error
        def initialize(klass, names)
          @klass = klass
          @names = names
        end

        def message
          "Missing dependency(ies) for #{@klass}: #{@names.map(&:to_s).join(', ')}"
        end
      end

      # Raised when you're providing undeclared dependency.
      class UnexpectedDependencyError < Error
        def initialize(klass, names)
          @klass = klass
          @names = names
        end

        def message
          "Unexpected dependency(ies) for #{@klass}: #{@names.map(&:to_s).join(', ')}"
        end
      end

      # Raised when dependency has unexpected type.
      class UnexpectedDependencyTypeError < Error
        def initialize(klass, name, value, type)
          @klass = klass
          @_name = name
          @value = value
          @_type = type
        end

        def message
          "#{@_name} dependency for #{@klass} has wrong type, must conform `#{@_type.inspect}`: `#{@value.inspect}`"
        end
      end

      # Raised when an optional dependency has no default value.
      class MissingDependencyDefaultError < Error
        def initialize(klass, name)
          @klass = klass
          @_name = name
        end

        def message
          "Optional dependency #{@_name} for #{@klass} has no default value"
        end
      end
    end
  end
end
