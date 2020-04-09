require 'spec_helper'

RSpec.describe Flows::Contract do
  describe '.make' do
    let(:contract) do
      described_class.make do
        transformer(either(String, Symbol), &:to_sym)
      end
    end

    it 'works' do
      expect(contract.transform!('aaa')).to eq :aaa
    end
  end
end
