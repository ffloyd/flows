require 'spec_helper'

RSpec.describe Flows::Operation do
  describe 'step definition by symbol' do
    context 'when instance method with same name exists' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data

          def build_result(**)
            ok(data: 'some data')
          end
        end
      end

      it 'uses this method as step body' do
        expect(invoke.unwrap).to eq(data: 'some data')
      end
    end

    context 'when no instance method with such name' do
      subject(:build) { operation_class.new }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data
        end
      end

      it 'raises error when building' do
        expect { build }.to raise_error Flows::Operation::NoStepImplementationError, /build_result/
      end
    end
  end

  describe 'success shape with implicit default status' do
    context 'when defined, result has :success status and data conforms shape' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data

          def build_result(**)
            ok(data: 'data', not_a_data: 'not a data')
          end
        end
      end

      it { is_expected.to be_ok }

      it 'returns filtered data' do
        expect(invoke.unwrap).to eq(data: 'data')
      end
    end

    context 'when defined, result has :success status and data does not conform shape' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data

          def build_result(**)
            ok(out_of_shape: 'data', not_a_data: 'not a data')
          end
        end
      end

      it 'raises exception on execution' do
        expect { invoke }.to raise_error Flows::Operation::MissingOutputError, /data/
      end
    end

    context 'when defined, result has non-standard status' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data

          def build_result(**)
            ok(:custom_status, data: 'data', not_a_data: 'not a data')
          end
        end
      end

      it 'raises exception on execution' do
        expect { invoke }.to raise_error Flows::Operation::UnexpectedSuccessStatusError, /custom_status/
      end
    end

    context 'when undefined' do
      subject(:build) { operation_class.new }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          def build_result(**)
            ok(data: 'data', not_a_data: 'not a data')
          end
        end
      end

      it 'raises exception when building' do
        expect { build }.to raise_error Flows::Operation::NoSuccessShapeError
      end
    end
  end

  describe 'success shapes with explicit statuses' do
    context 'when result conforms status and shape' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success type_a: %i[data],
                  type_b: %i[value]

          def build_result(**)
            ok(:type_b, value: 'some value')
          end
        end
      end

      it { is_expected.to be_ok }

      it 'returns expected status' do
        expect(invoke.status).to eq :type_b
      end

      it 'returns expected data' do
        expect(invoke.unwrap).to eq(value: 'some value')
      end
    end

    context 'when result status mistmatches' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success type_a: %i[data],
                  type_b: %i[value]

          def build_result(**)
            ok(value: 'some value')
          end
        end
      end

      it 'raises exception on execution' do
        expect { invoke }.to raise_error Flows::Operation::UnexpectedSuccessStatusError
      end
    end
  end

  describe 'failure shape with implicit default status' do
    context 'when defined, result has :failure status and data conforms shape' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data
          failure :error

          def build_result(**)
            err(error: 'some error', data: 'data')
          end
        end
      end

      it { is_expected.to be_err }

      it 'returns filtered data' do
        expect(invoke.error).to eq(error: 'some error')
      end
    end

    context 'when defined, result has :failure status and data does not conform shape' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data
          failure :error

          def build_result(**)
            err(data: 'some data')
          end
        end
      end

      it 'raises exception on execution' do
        expect { invoke }.to raise_error Flows::Operation::MissingOutputError, /error/
      end
    end

    context 'when defined, result has non-standard status' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data
          failure :error

          def build_result(**)
            err(:custom_status, error: 'some error')
          end
        end
      end

      it 'raises exception on execution' do
        expect { invoke }.to raise_error Flows::Operation::UnexpectedFailureStatusError, /custom_status/
      end
    end

    context 'when undefined' do
      subject(:build) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data

          def build_result(**)
            err(error: 'some error')
          end
        end
      end

      it 'raises exception on execution' do
        expect { build }.to raise_error Flows::Operation::NoFailureShapeError
      end
    end
  end

  describe 'failure shapes with explicit statuses' do
    context 'when result conforms status and shape' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data
          failure validation: %i[errors],
                  exception: %i[exceptions]

          def build_result(**)
            err(:validation, errors: 'some errors')
          end
        end
      end

      it { is_expected.to be_err }

      it 'returns expected status' do
        expect(invoke.status).to eq :validation
      end

      it 'returns expected data' do
        expect(invoke.error).to eq(errors: 'some errors')
      end
    end

    context 'when result status mistmatches' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data
          failure validation: %i[errors],
                  exception: %i[exceptions]

          def build_result(**)
            err(:unexpected, errors: 'some errors')
          end
        end
      end

      it 'raises exception on execution' do
        expect { invoke }.to raise_error Flows::Operation::UnexpectedFailureStatusError
      end
    end
  end

  describe 'override standard routing' do
    context 'when overrides default routing' do
      subject(:operation) { operation_class.new }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :resolve,
               match_ok => :term,
               match_err => :last_step

          step :last_step

          success :data

          def resolve(path:, **)
            case path
            when :ok then ok(data: 'ok path')
            when :err then err(data: 'err path')
            end
          end

          def last_step(**)
            ok(data: 'from last step')
          end
        end
      end

      it 'overrides ok result routing' do
        expect(operation.call(path: :ok).unwrap[:data]).to eq 'ok path'
      end

      it 'overrides err result routing' do
        expect(operation.call(path: :err).unwrap[:data]).to eq 'from last step'
      end
    end

    context 'when overrides status-specific routing' do
      subject(:operation) { operation_class.new }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :resolve, match_ok(:end_now) => :term
          step :last_step

          success success: [:data],
                  end_now: [:data]

          def resolve(path:, **)
            case path
            when :ok then ok(data: 'ok path')
            when :ok_end_now then ok(:end_now, data: 'ok short path')
            end
          end

          def last_step(**)
            ok(data: 'from last step')
          end
        end
      end

      it 'preserves standard roting for ok' do
        expect(operation.call(path: :ok).unwrap[:data]).to eq 'from last step'
      end

      it 'adds status specific routing' do
        expect(operation.call(path: :ok_end_now).unwrap[:data]).to eq 'ok short path'
      end
    end
  end
end
