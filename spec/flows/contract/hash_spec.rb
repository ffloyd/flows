require 'spec_helper'

RSpec.describe Flows::Contract::Hash do
  context 'with hash type for positive numbers dictionary' do
    let(:contract) do
      described_class.new(Symbol, pos_number_type)
    end

    let(:pos_number_type) do
      Flows::Contract::Predicate.new 'must be a positive number' do |x|
        x.is_a?(Numeric) && x.positive?
      end
    end

    it_behaves_like 'Flows::Contract with valid value',
                    value: { a: 1, b: 20 },
                    after_transform: { a: 1, b: 20 }

    error_message = "hash key `\"a\"` is invalid:\n" \
                    "    must match `Symbol`\n" \
                    "hash value `-10` is invalid:\n" \
                    '    must be a positive number'

    it_behaves_like 'Flows::Contract with invalid value',
                    value: { 'a' => 1, b: -10 },
                    error_message: error_message
  end

  context 'with value transformations' do
    let(:contract) do
      described_class.new(
        Flows::Contract::Transformer.new(String, &:strip),
        Flows::Contract::Transformer.new(String, &:upcase)
      )
    end

    it_behaves_like 'Flows::Contract with valid value',
                    value: { '  aa  ' => 'aa' },
                    after_transform: { 'aa' => 'AA' }

    error_message = "hash key `1` is invalid:\n" \
                    "    must match `String`\n" \
                    "hash value `2` is invalid:\n" \
                    '    must match `String`'

    it_behaves_like 'Flows::Contract with invalid value',
                    value: { 1 => 2 },
                    error_message: error_message
  end
end
