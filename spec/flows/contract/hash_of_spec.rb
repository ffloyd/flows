require 'spec_helper'

RSpec.describe Flows::Contract::HashOf do
  context 'with hash type for point' do
    let(:contract) do
      described_class.new(x: Float, y: Float)
    end

    it_behaves_like 'Flows::Contract with valid value',
                    value: { x: 1.0, y: 20.0, name: 'Vasya' },
                    after_transform: { x: 1.0, y: 20.0 }

    error_message = "missing key `:x`\n" \
                    "key `:y` has an invalid value:\n" \
                    '    must match `Float`'

    it_behaves_like 'Flows::Contract with invalid value',
                    value: { y: '10' },
                    error_message: error_message
  end
end
