require 'spec_helper'

require_relative '../support/operation_examples'

RSpec.describe Flows::Operation do
  subject(:invoke) { operation.new.call(params) }

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

  describe 'when no success output configuration provided' do
    let(:operation) do
      Class.new do
        include Flows::Operation

        step :be_ok

        failure :error

        def be_ok(**)
          ok(result: :ok)
        end
      end
    end

    it 'raises error on initialization' do
      expect { operation.new }.to raise_error described_class::NoSuccessShapeError
    end
  end

  describe 'when no failure output configuration provided' do
    let(:operation) do
      Class.new do
        include Flows::Operation

        step :be_ok

        success :result

        def be_ok(should_fail:, **)
          if should_fail
            err(wtf: :i_dont_know)
          else
            ok(result: :ok)
          end
        end
      end
    end

    context 'when success result generated' do
      let(:params) do
        { should_fail: false }
      end

      it { expect(invoke).to be_success }
    end

    context 'when failure result generated' do
      let(:params) do
        { should_fail: true }
      end

      it do
        expect { invoke }.to raise_error described_class::NoFailureShapeError
      end
    end
  end

  describe 'when no steps defined' do
    let(:operation) do
      Class.new do
        include Flows::Operation

        success :result
        failure :error
      end
    end

    it do
      expect { operation.new }.to raise_error described_class::NoStepsError
    end
  end

  describe 'when step implementation missed' do
    let(:operation) do
      Class.new do
        include Flows::Operation

        step :without_implementation

        success :result
        failure :error
      end
    end

    it do
      expect { operation.new }.to raise_error described_class::NoStepImplementationError
    end
  end

  describe 'when some success output key not generated' do
    let(:operation) do
      Class.new do
        include Flows::Operation

        step :do_job

        success :output_a, :output_b
        failure :error

        def do_job(**)
          ok(output_a: :ok)
        end
      end
    end

    let(:params) { {} }

    it do
      expect { invoke }.to raise_error described_class::MissingOutputError
    end
  end

  describe 'when some failure output key not generated' do
    let(:operation) do
      Class.new do
        include Flows::Operation

        step :do_job

        success :output_a, :output_b
        failure :error

        def do_job(**)
          err(wrong_key: :ok)
        end
      end
    end

    let(:params) { {} }

    it do
      expect { invoke }.to raise_error described_class::MissingOutputError
    end
  end
end
