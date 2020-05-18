require 'spec_helper'

RSpec.describe Flows::Contract::Compose do
  context 'with empty composition' do
    let(:contract) { described_class.new }

    it { expect { contract }.to raise_error StandardError }
  end

  context 'with one contract' do
    let(:contract) do
      described_class.new(String)
    end

    it_behaves_like 'Flows::Contract with valid value',
                    value: 'aaa'

    it_behaves_like 'Flows::Contract with invalid value',
                    value: 111
  end

  context 'with 2 contracts without transforms' do
    let(:contract) do
      described_class.new(String, /\A\d+\z/)
    end

    it_behaves_like 'Flows::Contract with valid value',
                    value: '111'

    it_behaves_like 'Flows::Contract with invalid value',
                    value: 111

    it_behaves_like 'Flows::Contract with invalid value',
                    value: 'aaa'
  end

  context 'with 2 contracts with transforms' do
    let(:contract) do
      described_class.new(
        Flows::Contract::Transformer.new(String, &:strip),
        Flows::Contract::Transformer.new(String, &:upcase)
      )
    end

    it_behaves_like 'Flows::Contract with valid value',
                    value: '  megatron  ',
                    after_transform: 'MEGATRON'

    it_behaves_like 'Flows::Contract with invalid value',
                    value: 111
  end
end
