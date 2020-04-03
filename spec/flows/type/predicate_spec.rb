require 'spec_helper'

RSpec.describe Flows::Type::Predicate do
  let(:type) do
    described_class.new(error_message) do |x|
      x == :expected_value
    end
  end

  let(:error_message) { 'error!' }

  it_behaves_like Flows::Type,
                  correct_value: :expected_value,
                  invalid_value: :unexepected_value,
                  error_message: 'error!'
end
