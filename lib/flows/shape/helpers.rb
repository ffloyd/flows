require 'forwardable'

# rubocop:disable Style/AccessModifierDeclarations

module Flows
  class Shape
    # Module with helpers for building shapes.
    #
    # Adds following methods as private:
    #
    # * `match(obj, errror)` - shortcut to {Match#initialize}
    # * `predicate(error, &block)` - shortcut to {Predicate#initialize}
    module Helpers
      extend Forwardable

      def_delegator Match, :new, :match
      private :match

      def_delegator Predicate, :new, :predicate
      private :predicate
    end
  end
end

# rubocop:enable Style/AccessModifierDeclarations
