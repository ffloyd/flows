require 'spec_helper'

RSpec.describe Flows::Plugin::Profiler::Report::Raw do
  subject(:report) { described_class.new }

  let(:klass) { Class.new }

  describe '#add' do
    subject(:raw_data) { report.raw_data }

    before do
      report.add(:started, klass, :singleton, :perform, nil)
      report.add(:finished, klass, :singleton, :perform, 10.5)
    end

    it do
      expect(raw_data).to eq([
                               [:started, klass, :singleton, :perform, nil],
                               [:finished, klass, :singleton, :perform, 10.5]
                             ])
    end
  end

  describe '#to_s' do
    subject(:text) { report.to_s }

    before do
      report.add(:started,  klass, :singleton, :perform, nil)
      report.add(:finished, klass, :singleton, :perform, 10.5)
    end

    it { is_expected.to be_a String }
  end

  describe '#events' do
    subject(:events) { report.events }

    before do
      report.add(:started,  klass, :singleton, :perform, nil)
      report.add(:finished, klass, :singleton, :perform, 10.5)
    end

    it 'returns array of events' do
      expect(events).to match([
                                instance_of(described_class::StartEvent),
                                instance_of(described_class::FinishEvent)
                              ])
    end
  end
end
