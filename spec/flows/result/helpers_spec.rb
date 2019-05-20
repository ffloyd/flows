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

      it { is_expected.to be_a Flows::Result::Ok }

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

      it { is_expected.to be_a Flows::Result::Err }

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

  # rubocop:disable Style/CaseEquality
  describe '#match_ok' do
    context 'without arguments' do
      subject(:matcher) { match_ok }

      it 'matches successful result with default status' do
        expect(matcher === ok(some: :data)).to be true
      end

      it 'matches successful result with custom status' do
        expect(matcher === ok(:hooray, some: :data)).to be true
      end

      it 'does not match failure result' do
        expect(matcher === err(some: :error)).to be false
      end
    end

    context 'with explicit status' do
      subject(:matcher) { match_ok(status) }

      let(:status) { :explicit_status }

      it 'matches successful result with same status' do
        expect(matcher === ok(status, some: :data)).to be true
      end

      it 'does not match successful result with different status' do
        expect(matcher === ok(:ahother_status, some: :data)).to be false
      end

      it 'does not match failure result' do
        expect(matcher === err(some: :error)).to be false
      end
    end
  end

  describe '#match_err' do
    context 'without arguments' do
      subject(:matcher) { match_err }

      it 'matches failure result with default status' do
        expect(matcher === err(some: :data)).to be true
      end

      it 'matches faiure result with custom status' do
        expect(matcher === err(:hooray, some: :data)).to be true
      end

      it 'does not match successful result' do
        expect(matcher === ok(some: :data)).to be false
      end
    end

    context 'with explicit status' do
      subject(:matcher) { match_err(status) }

      let(:status) { :explicit_status }

      it 'matches failure result with same status' do
        expect(matcher === err(status, some: :data)).to be true
      end

      it 'does not match failure result with different status' do
        expect(matcher === err(:ahother_status, some: :data)).to be false
      end

      it 'does not match successful result' do
        expect(matcher === ok(some: :data)).to be false
      end
    end
  end
  # rubocop:enable Style/CaseEquality
end
