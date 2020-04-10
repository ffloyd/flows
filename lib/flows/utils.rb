module Flows
  # Namespace for low-level purely technical OOP helpers.
  #
  # @since 0.4.0
  module Utils
  end
end

require_relative './utils/prepend_to_class'
require_relative './utils/dependency_injector'
require_relative './utils/implicit_init'
require_relative './utils/inheritable_singleton_vars'
