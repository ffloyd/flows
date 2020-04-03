require 'forwardable'

# rubocop:disable Style/AccessModifierDeclarations

module Flows
  class Type
    # Module with helpers for building shapes.
    #
    # Adds following methods as private:
    #
    # * `match(obj, errror)` - shortcut to {Match#initialize}
    # * `predicate(error, &block)` - shortcut to {Predicate#initialize}
    module Helpers
      extend Forwardable

      def_delegator Ruby, :new, :ruby
      module_function :ruby

      def_delegator Predicate, :new, :predicate
      module_function :predicate
    end
  end
end

# rubocop:enable Style/AccessModifierDeclarations
