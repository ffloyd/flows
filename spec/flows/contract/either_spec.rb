require 'spec_helper'

RSpec.describe Flows::Contract::Either do
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
                    value: 111,
                    error_message: 'must match `String`'
  end

  context 'with 2 contracts without transforms' do
    let(:contract) do
      described_class.new(String, Symbol)
    end

    it_behaves_like 'Flows::Contract with valid value',
                    value: :aaa

    it_behaves_like 'Flows::Contract with valid value',
                    value: 'aaa'

    error_message = "must match `String`\n" \
                    'OR must match `Symbol`'

    it_behaves_like 'Flows::Contract with invalid value',
                    value: 111,
                    error_message: error_message
  end

  context 'with 2 contracts with transforms' do
    let(:contract) do
      described_class.new(
        Flows::Contract::Transformer.new(String, &:strip),
        Flows::Contract::Transformer.new(Symbol, &:to_s)
      )
    end

    it_behaves_like 'Flows::Contract with valid value',
                    value: '  megatron  ',
                    after_transform: 'megatron'

    it_behaves_like 'Flows::Contract with valid value',
                    value: :megatron,
                    after_transform: 'megatron'

    error_message = "must match `String`\n" \
                    'OR must match `Symbol`'

    it_behaves_like 'Flows::Contract with invalid value',
                    value: 111,
                    error_message: error_message
  end
end
