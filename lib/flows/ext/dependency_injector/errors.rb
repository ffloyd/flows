module Flows
  module Ext
    module DependencyInjector
      # Base error class for dependency injection errors.
      class Error < ::Flows::Error; end

      # Raised when you're missed some dependency.
      class MissingDependencyError < Error
      end

      # Raised when you're providing undeclared dependency.
      class UnexpectedDependencyError < Error
      end

      # Raised when dependency has unexpected type.
      class UnexpectedDependencyTypeError < Error
      end

      # Raised when an optional dependency has no default value.
      class MissingDependencyDefaultError < Error
      end
    end
  end
end
