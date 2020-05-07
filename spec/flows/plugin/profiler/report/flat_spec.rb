require 'spec_helper'

RSpec.describe Flows::Plugin::Profiler::Report::Flat do
  subject(:report) { described_class.new }

  let(:klass) do
    Class.new do
      def self.to_s
        'ClassName'
      end
    end
  end

  before do
    report.add(:started, klass, :instance, :perform, nil)
    report.add(:finished, klass, :instance, :perform, 100.0)

    report.add(:started, klass, :singleton, :call, nil)
    report.add(:finished, klass, :singleton, :call, 100.0)

    report.add(:started, klass, :instance, :perform, nil)
    report.add(:started, klass, :singleton, :call, nil)
    report.add(:finished, klass, :singleton, :call, 50.0)
    report.add(:finished, klass, :instance, :perform, 200.0) # self time is 200 - 50 = 100
  end

  describe '#to_a' do
    subject(:report_hash) { report.to_a }

    let(:expected_report) do
      contain_exactly(
        match(
          subject: 'ClassName#perform',
          count: 2,
          total_self_ms: a_value_within(0.00001).of(0.25),
          total_self_percentage: a_value_within(0.00001).of(62.5),
          avg_self_ms: a_value_within(0.00001).of(0.125),
          direct_subcalls: ['ClassName.call']
        ),
        match(
          subject: 'ClassName.call',
          count: 2,
          total_self_ms: a_value_within(0.00001).of(0.15),
          total_self_percentage: a_value_within(0.00001).of(37.5),
          avg_self_ms: a_value_within(0.00001).of(0.075),
          direct_subcalls: []
        )
      )
    end

    it 'renders expected report' do
      expect(report_hash).to match expected_report
    end
  end

  describe '#to_s' do
    subject(:report_str) { report.to_s }

    it { is_expected.to be_a String }
  end
end
