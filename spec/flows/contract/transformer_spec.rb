require 'spec_helper'

RSpec.describe Flows::Contract::Transformer do
  let(:contract) { described_class.new(String, &:upcase) }

  it_behaves_like 'Flows::Contract with valid value',
                  value: 'aaa',
                  after_transform: 'AAA'

  it_behaves_like 'Flows::Contract with invalid value',
                  value: :AAA
end
