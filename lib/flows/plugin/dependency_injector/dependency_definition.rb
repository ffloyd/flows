module Flows
  module Plugin
    module DependencyInjector
      # Struct for storing dependency definitions.
      #
      # @api private
      DependencyDefinition = Struct.new(:name, :required, :default, :type, :klass, keyword_init: true) do
        def initialize(*)
          super

          raise MissingDependencyDefaultError.new(klass, name) if !required && (default == NO_DEFAULT)
        end
      end
    end
  end
end
