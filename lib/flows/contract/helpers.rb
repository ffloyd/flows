require 'forwardable'

module Flows
  class Contract
    # Shortcuts for contract creation.
    module Helpers
      extend Forwardable

      def_delegator CaseEq, :new, :case_eq
      def_delegator Predicate, :new, :predicate

      def_delegator Transformer, :new, :transformer
      def_delegator Compose, :new, :compose
      def_delegator Either, :new, :either

      def_delegator Flows::Contract::Hash, :new, :hash
      def_delegator HashOf, :new, :hash_of
      def_delegator Flows::Contract::Array, :new, :array
      def_delegator Tuple, :new, :tuple
    end
  end
end
