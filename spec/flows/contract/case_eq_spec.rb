require 'spec_helper'

RSpec.describe Flows::Contract::CaseEq do
  context 'with default error message' do
    let(:contract) { described_class.new(String) }

    it_behaves_like 'Flows::Contract with valid value',
                    value: 'AAA'

    it_behaves_like 'Flows::Contract with invalid value',
                    value: 111,
                    error_message: 'must match `String`'
  end

  context 'with custom error message' do
    let(:contract) { described_class.new(String, 'must be a string') }

    it_behaves_like 'Flows::Contract with invalid value',
                    value: 111,
                    error_message: 'must be a string'
  end
end
