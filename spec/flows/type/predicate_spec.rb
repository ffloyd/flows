require 'spec_helper'

RSpec.describe Flows::Type::Predicate do
  let(:type) do
    described_class.new 'must be :expected_value' do |x|
      x == :expected_value
    end
  end

  it_behaves_like 'Flows::Type with valid value',
                  value: :expected_value

  it_behaves_like 'Flows::Type with invalid value',
                  value: :unexepected_value,
                  error_message: 'must be :expected_value'
end
