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

    it_behaves_like 'Flows::Contract with invalid value',
                    value: { 'a' => 1, b: -10 }
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

    it_behaves_like 'Flows::Contract with invalid value',
                    value: { 1 => 2 }
  end
end
