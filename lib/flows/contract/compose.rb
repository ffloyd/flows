module Flows
  class Contract
    # Allows to combine two or more contracts.
    #
    # From type system perspective - this composition is intersection of types.
    # It means that value passes contract if it passes each particular contract in a composition.
    #
    # ## Composition and Transform Laws
    #
    # _Golden rule:_ don't use contracts with transformations in composition if you can.
    # In the most cases you can compose contracts without transformations
    # and apply one transformation to composite contract.
    #
    # Composition of contracts' transformations MUST obey Transform Laws (see {Contract} documentation for details).
    # To achieve this each particular transform MUST obey following additional laws:
    #
    #     # let `c` be a contract composition
    #
    #     # 1. each transform should not leave composite type
    #     #
    #     # for any `x` valid for composite type
    #     c.check!(x) == true
    #     # and for any contract `c_i` from composition:
    #     c.check!(c_i.transform!(x)) == true
    #
    #     # 2. tranforms can be applied in any order
    #     #
    #     # for any `x` valid for composite type
    #     c.check!(x) == true
    #     # for any two contracts `c_i` and `c_j` from composition:
    #     c_i(c_j(x)) == c_j(c_i(x))
    #
    # Why do we need the first law?
    # To prevent situations when original value matches composite type,
    # but transformed value doesn't. Example:
    #
    #     Flows::Contract.make do
    #       compose(
    #         transform(either(String, Symbol), &:to_sym),
    #         String
    #       )
    #     end
    #
    # Second laws makes composition of transforms to obey 2nd transform law.
    # Example of correct composable transforms:
    #
    #     Flows::Contract.make do
    #       compose(
    #         transform(String, &:strip),
    #         transform(String, &:trim)
    #       )
    #     end
    #
    # Formal proof is based on [this theorem proof](https://math.stackexchange.com/questions/600978/equivalence-relation-composition-problem).
    class Compose < Contract
      # @param contracts [Array<Contract, Object>] contract list. Non-contract elements will be wrapped with {CaseEq}.
      def initialize(*contracts)
        raise 'Contract list must not be empty' if contracts.length.zero?

        @contracts = contracts.map(&method(:to_contract))
      end

      # @see Contract#check!
      def check!(other)
        @contracts.each { |con| con.check!(other) }
        true
      end

      # @see Contract#transform!
      def transform!(other)
        @contracts.reduce(other) do |value, con|
          con.transform!(value)
        end
      end
    end
  end
end
