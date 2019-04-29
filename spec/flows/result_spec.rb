require 'spec_helper'

RSpec.describe Flows::Result do
  describe '.new' do
    subject(:invoke) { described_class.new('some', status: :whatever) }

    it 'is forbidden to build Result directly' do
      expect { invoke }.to raise_error StandardError
    end
  end
end
