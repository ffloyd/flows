module Flows
  # Namespace for class behaviour extensions.
  #
  # Feel free to use it to empower your abstractions.
  #
  # @since 0.4.0
  module Plugin
  end
end

require_relative 'plugin/dependency_injector'
require_relative 'plugin/implicit_init'
require_relative 'plugin/output_contract'
require_relative 'plugin/profiler'
require_relative 'plugin/interface'
