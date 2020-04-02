require 'spec_helper'

RSpec.describe Flows::Shape::Predicate do
  let(:shape) do
    described_class.new(error_message) do |x|
      x == :expected_value
    end
  end

  let(:error_message) { 'error!' }

  it_behaves_like 'Flows::Shape',
                  correct_value: :expected_value,
                  invalid_value: :unexepected_value,
                  error_message: 'error!'
end
