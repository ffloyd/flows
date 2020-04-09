module Flows
  class Contract
    # Adds transformation to an existing contract.
    #
    # If original contract already has a transform -
    # final transformation will be composition of original and new one.
    #
    # You MUST obey Transformation Laws (see {Contract} documentation for details).
    #
    # @example Upcase strings
    #     up_str = Flows::Contract::Transformer.new(String) { |str| str.upcase }
    #
    #     up_str.transform!('megatron')
    #     # => 'MEGATRON'
    #
    #     up_str.transform(:megatron).error
    #     # => 'must match `String`'
    #
    # @example Strip and upcase strings
    #     strip_str =  Flows::Contract::Transformer.new(String, &:strip)
    #     up_stip_str = Flows::Contract::Transformer.new(strip_str, &:upcase)
    #
    #     up_str.transform!('   megatron   ')
    #     # => 'MEGATRON'
    #
    #     up_str.cast(:megatron).error
    #     # => 'must match `String`'
    class Transformer < Contract
      # @param contract [Contract, Object] in case of non-contract argument {CaseEq} is automatically applied.
      # @yield [object] transform implementation
      # @yieldreturn [object] result of transform. Must obey transformation laws.
      def initialize(contract, &transform_proc)
        @contract = to_contract(contract)
        @transform = transform_proc
      end

      # @see Contract#check!
      def check!(other)
        @contract.check!(other)
      end

      # @see Contract#transform!
      def transform!(other)
        @transform.call(
          @contract.transform!(other)
        )
      end
    end
  end
end
