module Flows
  # Namespace for low-level purely technical OOP helpers.
  #
  # Implementations here are relatively complex and require
  # advanced understanding of Ruby's OOP and runtime.
  #
  # This module implements "hidden complexity" approach:
  # hide most non-trivial parts of implementation inside
  # small well-documented classes and modules.
  #
  # @since 0.4.0
  module Util
  end
end

require_relative 'util/prepend_to_class'
require_relative 'util/inheritable_singleton_vars'
