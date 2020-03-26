module Flows
  # Namespace for low-level purely technical OOP helpers.
  #
  # @since 0.4.0
  module Ext
  end
end

require_relative './ext/prepend_to_class'
require_relative './ext/dependency_injector'
require_relative './ext/implicit_init'
require_relative './ext/inheritable_singleton_vars'
