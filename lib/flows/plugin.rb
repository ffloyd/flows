module Flows
  # Namespace for class behaviour extensions.
  #
  # @since 0.4.0
  module Plugin
  end
end

require_relative 'plugin/dependency_injector'
require_relative 'plugin/implicit_init'
