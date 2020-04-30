require 'spec_helper'

RSpec.describe Flows::Contract::Tuple do
  context 'without transforms' do
    let(:contract) do
      described_class.new(Symbol, Integer)
    end

    it_behaves_like 'Flows::Contract with valid value',
                    value: [:a, 10]

    it_behaves_like 'Flows::Contract with invalid value',
                    value: %w[a b]

    it_behaves_like 'Flows::Contract with invalid value',
                    value: []
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

    it_behaves_like 'Flows::Contract with invalid value',
                    value: [1, 2]
  end
end
