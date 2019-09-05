require 'spec_helper'

RSpec.describe Flows::ResultRouter do
  include Flows::Result::Helpers

  describe '.call' do
    subject(:router) { described_class.new(:success, :failure) }

    it 'returns success path for success result' do
      expect(router.call(ok)).to eq :success
    end

    it 'returns failure path for success result' do
      expect(router.call(err)).to eq :failure
    end
  end
end
