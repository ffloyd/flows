require 'spec_helper'

RSpec.describe Flows::Type::Hash do
  context 'with hash type for positive numbers dictionary' do
    let(:type) do
      described_class.new(Symbol, pos_number_type)
    end

    let(:pos_number_type) do
      Flows::Type::Predicate.new 'must be a positive number' do |x|
        x.is_a?(Numeric) && x.positive?
      end
    end

    it_behaves_like 'Flows::Type with valid value',
                    value: { a: 1, b: 20 }

    error_message = "hash key `\"a\"` is invalid:\n" \
                    "    must match `Symbol`\n" \
                    "hash value `-10` is invalid:\n" \
                    '    must be a positive number'

    it_behaves_like 'Flows::Type with invalid value',
                    value: { 'a' => 1, b: -10 },
                    error_message: error_message
  end
end
