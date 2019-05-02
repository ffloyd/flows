require 'spec_helper'

require_relative '../support/operation_examples'

RSpec.describe Flows::Operation do
  let(:invoke) { operation.new.call(params) }

  describe 'simplest operation' do
    let(:operation) { OperationExamples::OneStep }

    context 'when success path' do
      let(:params) do
        {
          first: 10,
          second: 2
        }
      end

      it { expect(invoke).to be_success }

      it 'sets :result key in result' do
        expect(invoke.unwrap).to eq(result: 5)
      end
    end

    context 'when failure path' do
      let(:params) do
        {
          first: 10,
          second: 0
        }
      end

      it { expect(invoke).to be_failure }

      it 'sets :result key in result' do
        expect(invoke.error).to eq(error: :division_by_zero)
      end
    end
  end

  describe 'two success result variants and two errors variants' do
    let(:operation) { OperationExamples::DifferentOutputStatuses }

    context 'when success :team_red path' do
      let(:params) do
        {
          color: 'red',
          weapon_index: 0
        }
      end

      it { expect(invoke).to be_success }

      it 'has status :team_red' do
        expect(invoke.status).to eq :team_red
      end

      it do
        expect(invoke.unwrap).to eq(gun: 'rifle')
      end
    end

    context 'when success :team_blue path' do
      let(:params) do
        {
          color: 'blue',
          weapon_index: 1
        }
      end

      it { expect(invoke).to be_success }

      it 'has status :team_red' do
        expect(invoke.status).to eq :team_blue
      end

      it do
        expect(invoke.unwrap).to eq(blade: 'dagger')
      end
    end

    context 'when failure :unexisting_team path' do
      let(:params) do
        {
          color: 'black',
          weapon_index: 1
        }
      end

      it { expect(invoke).to be_failure }

      it 'has status :unexisting_team' do
        expect(invoke.status).to eq :unexisting_team
      end

      it do
        expect(invoke.error).to eq(color: 'black')
      end
    end

    context 'when failure :weapon_not_found path' do
      let(:params) do
        {
          color: 'red',
          weapon_index: 100
        }
      end

      it { expect(invoke).to be_failure }

      it 'has status :weapon_not_found' do
        expect(invoke.status).to eq :weapon_not_found
      end

      it do
        expect(invoke.error).to eq(set: operation::GUNS, index: 100)
      end
    end
  end
end
