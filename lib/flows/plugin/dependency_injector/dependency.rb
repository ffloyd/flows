module Flows
  module Plugin
    module DependencyInjector
      # Resolves dependency on initialization and can inject it into class instance.
      #
      # @api private
      Dependency = Struct.new(:name, :definition, :provided_value, :value, :klass, keyword_init: true) do
        def initialize(*)
          super

          self.value = provided_value == NO_VALUE ? definition.default : provided_value
          type = definition.type

          raise UnexpectedDependencyTypeError.new(klass, name, value, type) if type != NO_TYPE && !(type === value) # rubocop:disable Style/CaseEquality
        end

        def inject_to(instance)
          value = self.value
          instance.define_singleton_method(name) { value }
        end
      end
    end
  end
end
