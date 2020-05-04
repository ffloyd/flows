require 'spec_helper'

RSpec.describe Flows::Plugin::Profiler do
  let(:report) do
    instance_double(described_class::Report::Raw).tap do |dbl|
      allow(described_class::Report).to receive(:===).and_call_original
      allow(described_class::Report).to receive(:===).with(dbl).and_return true

      allow(dbl).to receive(:add)
    end
  end

  describe '.for_method' do
    subject(:generated_module) do
      described_class.for_method(:my_method)
    end

    it { is_expected.to be_a Module }
  end

  describe '.profile' do
    subject(:profile) do
      described_class.profile(report) do
        user_class.on_singleton
        user_class.new.on_instance
      end
    end

    let(:user_class) do
      Class.new do
        def on_instance
          :from_instance
        end

        def self.on_singleton
          :from_singleton
        end
      end
    end

    it 'returns block value' do
      expect(profile).to eq :from_instance
    end

    context 'with instance method' do
      before do
        user_class.include described_class.for_method(:on_instance)
      end

      it 'registers instance method call in report' do # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
        profile

        expect(report).to have_received(:add)
          .with(:started, user_class, :instance, :on_instance, nil)
          .ordered
        expect(report).to have_received(:add)
          .with(:finished, user_class, :instance, :on_instance, instance_of(Float))
          .ordered
      end
    end

    context 'with singleton method' do
      before do
        user_class.extend described_class.for_method(:on_singleton)
      end

      it 'registers singleton method call in report' do # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
        profile

        expect(report).to have_received(:add)
          .with(:started, user_class, :singleton, :on_singleton, nil)
          .ordered
        expect(report).to have_received(:add)
          .with(:finished, user_class, :singleton, :on_singleton, instance_of(Float))
          .ordered
      end
    end
  end

  describe '.last_report' do
    subject(:last_report) { described_class.last_report }

    before { described_class.reset }

    context 'when no profile happened' do
      it { is_expected.to be_nil }
    end

    context 'when profile with custom report' do
      before do
        described_class.profile(report) {}
      end

      it 'returns provided report' do
        expect(last_report).to eq report
      end
    end

    context 'when profile with default report' do
      before { described_class.profile {} }

      it 'returns raw report' do
        expect(last_report).to be_a described_class::Report::Raw
      end
    end
  end
end
