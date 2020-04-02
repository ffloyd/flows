require 'spec_helper'

RSpec.describe Flows::Shape::Match do
  let(:shape) { described_class.new(String) }

  it_behaves_like 'Flows::Shape',
                  correct_value: 'AAA',
                  invalid_value: 111,
                  error_message: 'must match `String`'

  context 'with custom error message' do
    let(:shape) { described_class.new(String, 'must be a string') }

    it_behaves_like 'Flows::Shape',
                    correct_value: 'AAA',
                    invalid_value: 111,
                    error_message: 'must be a string'
  end
end
