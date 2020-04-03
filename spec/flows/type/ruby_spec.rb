require 'spec_helper'

RSpec.describe Flows::Type::Ruby do
  context 'without custom error message' do
    let(:type) { described_class.new(String) }

    it_behaves_like Flows::Type,
                    correct_value: 'AAA',
                    invalid_value: 111,
                    error_message: 'must match `String`'
  end

  context 'with custom error message' do
    let(:type) { described_class.new(String, 'must be a string') }

    it_behaves_like Flows::Type,
                    correct_value: 'AAA',
                    invalid_value: 111,
                    error_message: 'must be a string'
  end
end
