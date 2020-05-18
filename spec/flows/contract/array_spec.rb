require 'spec_helper'

RSpec.describe Flows::Contract::Array do
  context 'without transformation' do
    let(:contract) do
      described_class.new(String)
    end

    it_behaves_like 'Flows::Contract with valid value',
                    value: %w[AAA BBB]

    it_behaves_like 'Flows::Contract with invalid value',
                    value: 111

    it_behaves_like 'Flows::Contract with invalid value',
                    value: ['AAA', 111]
  end

  context 'with transformation' do
    let(:contract) do
      described_class.new(
        Flows::Contract::Transformer.new(String, &:upcase)
      )
    end

    it_behaves_like 'Flows::Contract with valid value',
                    value: %w[aaa bbb],
                    after_transform: %w[AAA BBB]

    it_behaves_like 'Flows::Contract with invalid value',
                    value: 111
  end
end
