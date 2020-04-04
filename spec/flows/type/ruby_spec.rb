require 'spec_helper'

RSpec.describe Flows::Type::Ruby do
  let(:type) { described_class.new(String) }

  it_behaves_like 'Flows::Type with valid value',
                  value: 'AAA'

  it_behaves_like 'Flows::Type with invalid value',
                  value: 111,
                  error_message: 'must match `String`'

  context 'with custom error message' do
    let(:type) { described_class.new(String, 'must be a string') }

    it_behaves_like 'Flows::Type with invalid value',
                    value: 111,
                    error_message: 'must be a string'
  end
end
