require 'spec_helper'

RSpec.describe Flows::Contract::HashOf do
  context 'with hash contract for point' do
    let(:contract) do
      described_class.new(x: Float, y: Float)
    end

    it_behaves_like 'Flows::Contract with valid value',
                    value: { x: 1.0, y: 20.0, name: 'Vasya' },
                    after_transform: { x: 1.0, y: 20.0 }

    it_behaves_like 'Flows::Contract with invalid value',
                    value: { y: '10' }
  end

  context 'with hash contract with transforms' do
    let(:contract) do
      described_class.new(
        s: Flows::Contract::Transformer.new(String, &:strip),
        u: Flows::Contract::Transformer.new(String, &:upcase)
      )
    end

    it_behaves_like 'Flows::Contract with valid value',
                    value: { s: '  aa  ', u: ' aa ', name: 'Vasya' },
                    after_transform: { s: 'aa', u: ' AA ' }

    it_behaves_like 'Flows::Contract with invalid value',
                    value: { u: 10 }
  end
end
