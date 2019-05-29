require 'spec_helper'

RSpec.describe Flows::Result::Ok do
  subject(:result) { described_class.new(data) }

  let(:data) { double }

  describe '.new' do
    it 'creates result without errors' do
      expect { result }.not_to raise_error
    end
  end

  describe '#ok?' do
    it { expect(result).to be_ok }
  end

  describe '#err?' do
    it { expect(result).not_to be_err }
  end

  describe '#unwrap' do
    subject(:unwrap) { result.unwrap }

    it 'returns data' do
      expect(unwrap).to eq data
    end
  end

  describe '#error' do
    subject(:error) { result.error }

    it 'raises exception' do
      expect { error }.to raise_error Flows::Result::NoErrorError
    end
  end

  describe '#status' do
    subject(:status) { result.status }

    context 'with default status' do
      it { expect(status).to eq :success }
    end

    context 'with explicit status' do
      let(:result) { described_class.new(data, status: provided_status) }
      let(:provided_status) { :provided_status }

      it { expect(status).to eq provided_status }
    end
  end

  describe '#meta' do
    subject(:meta) { result.meta }

    context 'with default meta' do
      it { expect(meta).to eq({}) }
    end

    context 'with explicit meta' do
      let(:result) { described_class.new(data, meta: provided_meta) }
      let(:provided_meta) { { provided: :meta } }

      it { expect(meta).to eq provided_meta }
    end
  end
end
