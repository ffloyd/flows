require 'spec_helper'

RSpec.describe Flows::Plugin::OutputContract do
  context 'when no output contract defined' do
    subject(:klass) do
      Class.new do
        include Flows::Plugin::OutputContract

        def call
          nil
        end
      end
    end

    it do
      expect { klass.new }.to raise_error described_class::NoContractError
    end
  end

  context 'when #call returns not a Result Object' do
    subject(:invoke) { klass.new.call }

    let(:klass) do
      Class.new do
        include Flows::Plugin::OutputContract

        success_with :ok do
          String
        end

        def call
          'AAAA'
        end
      end
    end

    it do
      expect { invoke }.to raise_error described_class::ResultTypeError
    end
  end

  context 'when #call returns successful Result with unexpected status' do
    subject(:invoke) { klass.new.call }

    let(:klass) do
      Class.new do
        include Flows::Plugin::OutputContract
        include Flows::Result::Helpers

        success_with :ok do
          String
        end

        def call
          ok_data('AAAA', status: :unexpected)
        end
      end
    end

    it do
      expect { invoke }.to raise_error described_class::StatusError
    end
  end

  context 'when #call returns failure Result with unexpected status' do
    subject(:invoke) { klass.new.call }

    let(:klass) do
      Class.new do
        include Flows::Plugin::OutputContract
        include Flows::Result::Helpers

        success_with :ok do
          String
        end

        failure_with :err do
          String
        end

        def call
          err_data('AAAA', status: :unexpected)
        end
      end
    end

    it do
      expect { invoke }.to raise_error described_class::StatusError
    end
  end

  context 'when #call returns successful Result with unexpected data' do
    subject(:invoke) { klass.new.call }

    let(:klass) do
      Class.new do
        include Flows::Plugin::OutputContract
        include Flows::Result::Helpers

        success_with :ok do
          String
        end

        def call
          ok_data(:AAAA)
        end
      end
    end

    it do
      expect { invoke }.to raise_error described_class::ContractError
    end
  end

  context 'when #call returns failure Result with unexpected data' do
    subject(:invoke) { klass.new.call }

    let(:klass) do
      Class.new do
        include Flows::Plugin::OutputContract
        include Flows::Result::Helpers

        success_with :ok do
          Symbol
        end

        failure_with :err do
          String
        end

        def call
          err_data(:AAAA)
        end
      end
    end

    it do
      expect { invoke }.to raise_error described_class::ContractError
    end
  end

  context 'when successful contract is met' do
    subject(:invoke) { klass.new.call }

    let(:klass) do
      Class.new do
        include Flows::Plugin::OutputContract
        include Flows::Result::Helpers

        success_with :ok do
          transformer(either(String, Symbol), &:to_sym)
        end

        def call
          ok_data('AAAA')
        end
      end
    end

    it 'returns Result object with transformed data' do
      expect(invoke.unwrap).to eq :AAAA
    end
  end

  context 'when failure contract is met' do
    subject(:invoke) { klass.new.call }

    let(:klass) do
      Class.new do
        include Flows::Plugin::OutputContract
        include Flows::Result::Helpers

        success_with :ok do
          String
        end

        failure_with :err do
          transformer(either(String, Symbol), &:to_sym)
        end

        def call
          err_data('AAAA')
        end
      end
    end

    it 'returns Result object with transformed data' do
      expect(invoke.error).to eq :AAAA
    end
  end

  context 'when contract is inherited' do
    subject(:invoke) { klass.new.call }

    let(:klass) { Class.new(parent_class) }

    let(:parent_class) do
      Class.new do
        include Flows::Plugin::OutputContract
        include Flows::Result::Helpers

        success_with :ok do
          transformer(either(String, Symbol), &:to_sym)
        end

        def call
          ok_data('AAAA')
        end
      end
    end

    it 'returns Result object with transformed data' do
      expect(invoke.unwrap).to eq :AAAA
    end
  end

  context 'when contract disabled' do
    subject(:invoke) { klass.new.call }

    let(:klass) do
      Class.new do
        include Flows::Plugin::OutputContract
        include Flows::Result::Helpers

        success_with :ok do
          String
        end

        failure_with :err do
          transformer(either(String, Symbol), &:to_sym)
        end

        skip_output_contract

        def call
          err_data('AAAA')
        end
      end
    end

    it 'returns Result object with non-transformed data' do
      expect(invoke.error).to eq 'AAAA'
    end
  end
end
