module Flows
  module Utils
    module DependencyInjector
      # Struct for storing dependency definitions.
      #
      # @api private
      DependencyDefinition = Struct.new(:required, :default, :type, keyword_init: true) do
        def initialize(*)
          super

          raise MissingDependencyDefaultError if !required && (default == NO_DEFAULT)
        end
      end
    end
  end
end
