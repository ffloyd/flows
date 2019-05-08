require 'spec_helper'

RSpec.describe Flows::Result::Helpers do
  include described_class

  describe '#ok' do
    context 'without status code' do
      subject(:result) { ok(data) }

      let(:data) do
        {
          some: :data
        }
      end

      it { is_expected.to be_a Flows::Result::Success }

      it 'has :success status' do
        expect(result.status).to eq :success
      end

      it 'has provided data' do
        expect(result.unwrap).to eq data
      end
    end

    context 'with explicit status code' do
      subject(:result) { ok(status, data) }

      let(:data) do
        {
          some: :data
        }
      end

      let(:status) { :explicit }

      it 'has provided status' do
        expect(result.status).to eq status
      end

      it 'has provided data' do
        expect(result.unwrap).to eq data
      end
    end
  end

  describe '#err' do
    context 'without status code' do
      subject(:result) { err(data) }

      let(:data) do
        {
          some: :data
        }
      end

      it { is_expected.to be_a Flows::Result::Failure }

      it 'has :failure status' do
        expect(result.status).to eq :failure
      end

      it 'has provided data' do
        expect(result.error).to eq data
      end
    end

    context 'with explicit status code' do
      subject(:result) { err(status, data) }

      let(:data) do
        {
          some: :data
        }
      end

      let(:status) { :explicit }

      it 'has provided status' do
        expect(result.status).to eq status
      end

      it 'has provided data' do
        expect(result.error).to eq data
      end
    end
  end
end
