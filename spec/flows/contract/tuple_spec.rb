require 'spec_helper'

RSpec.describe Flows::Contract::Tuple do
  context 'without transforms' do
    let(:contract) do
      described_class.new(Symbol, Integer)
    end

    it_behaves_like 'Flows::Contract with valid value',
                    value: [:a, 10]

    error_message = "array element `\"a\"` with index 0 is invalid:\n" \
                    "    must match `Symbol`\n" \
                    "array element `\"b\"` with index 1 is invalid:\n" \
                    '    must match `Integer`'

    it_behaves_like 'Flows::Contract with invalid value',
                    value: %w[a b],
                    error_message: error_message

    it_behaves_like 'Flows::Contract with invalid value',
                    value: [],
                    error_message: 'array length mismatch: must be 2, got 0'
  end

  context 'with transforms' do
    let(:contract) do
      described_class.new(
        Flows::Contract::Transformer.new(String, &:strip),
        Flows::Contract::Transformer.new(String, &:upcase)
      )
    end

    it_behaves_like 'Flows::Contract with valid value',
                    value: [' aa ', ' bb '],
                    after_transform: ['aa', ' BB ']

    error_message = "array element `1` with index 0 is invalid:\n" \
                    "    must match `String`\n" \
                    "array element `2` with index 1 is invalid:\n" \
                    '    must match `String`'

    it_behaves_like 'Flows::Contract with invalid value',
                    value: [1, 2],
                    error_message: error_message
  end
end
