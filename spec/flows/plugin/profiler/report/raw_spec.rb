require 'spec_helper'

RSpec.describe Flows::Plugin::Profiler::Report::Raw do
  subject(:raw_report) { described_class.new }

  let(:klass) { Class.new }

  describe '#add' do
    subject(:raw_data) { raw_report.raw_data }

    before do
      raw_report.add(:started, klass, :singleton, :perform, nil)
      raw_report.add(:finished, klass, :singleton, :perform, 10.5)
    end

    it do
      expect(raw_data).to eq([
                               [:started, klass, :singleton, :perform, nil],
                               [:finished, klass, :singleton, :perform, 10.5]
                             ])
    end
  end

  describe '#to_s' do
    subject(:text) { raw_report.to_s }

    before do
      raw_report.add(:started,  klass, :singleton, :perform, nil)
      raw_report.add(:finished, klass, :singleton, :perform, 10.5)
    end

    it { is_expected.to be_a String }
  end
end
