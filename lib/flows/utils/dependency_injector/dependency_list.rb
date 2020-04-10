module Flows
  module Utils
    module DependencyInjector
      # Resolves dependencies on initialization and can inject it into class instance.
      #
      # @api private
      class DependencyList
        attr_reader :definitions
        attr_reader :provided_values
        attr_reader :dependencies

        def initialize(definitions:, provided_values:)
          @definitions = definitions
          @provided_values = provided_values.dup.tap { |pv| pv.default = NO_VALUE }

          check_missing_dependencies
          check_unexpected_dependencies
          resolve_dependencies
        end

        def inject_to(instance)
          dependencies.each { |dep| dep.inject_to(instance) }
        end

        private

        def required_dependencies
          definitions.select { |_, definition| definition.required }.keys
        end

        def check_missing_dependencies
          missing = required_dependencies - provided_values.keys

          raise MissingDependencyError if missing.any?
        end

        def check_unexpected_dependencies
          unexpected = provided_values.keys - definitions.keys

          raise UnexpectedDependencyError if unexpected.any?
        end

        def resolve_dependencies
          @dependencies = definitions.map do |name, definition|
            Dependency.new(
              name: name,
              definition: definition,
              provided_value: provided_values[name]
            )
          end
        end
      end
    end
  end
end
