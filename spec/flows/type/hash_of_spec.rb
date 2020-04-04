require 'spec_helper'

RSpec.describe Flows::Type::HashOf do
  context 'with hash type for point' do
    let(:type) do
      described_class.new(x: Float, y: Float)
    end

    it_behaves_like 'Flows::Type with valid value',
                    value: { x: 1.0, y: 20.0, name: 'Vasya' },
                    after_cast: { x: 1.0, y: 20.0 }

    error_message = "missing key `:x`\n" \
                    "key `:y` has an invalid value:\n" \
                    '    must match `Float`'

    it_behaves_like 'Flows::Type with invalid value',
                    value: { y: '10' },
                    error_message: error_message
  end
end
