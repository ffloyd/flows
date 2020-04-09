require 'spec_helper'

RSpec.describe Flows::Contract::Array do
  context 'without transformation' do
    let(:contract) do
      described_class.new(String)
    end

    it_behaves_like 'Flows::Contract with valid value',
                    value: %w[AAA BBB]

    it_behaves_like 'Flows::Contract with invalid value',
                    value: 111,
                    error_message: 'must match `Array`'

    error_message = "array element `111` is invalid:\n" \
                    '    must match `String`'

    it_behaves_like 'Flows::Contract with invalid value',
                    value: ['AAA', 111],
                    error_message: error_message
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
                    value: 111,
                    error_message: 'must match `Array`'
  end
end
