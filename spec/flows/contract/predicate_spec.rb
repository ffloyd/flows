require 'spec_helper'

RSpec.describe Flows::Contract::Predicate do
  let(:contract) do
    described_class.new 'must be :expected_value' do |x|
      x == :expected_value
    end
  end

  it_behaves_like 'Flows::Contract with valid value',
                  value: :expected_value

  it_behaves_like 'Flows::Contract with invalid value',
                  value: :unexepected_value,
                  error_message: 'must be :expected_value'
end
