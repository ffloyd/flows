require 'spec_helper'

RSpec.describe Flows::Plugin::Profiler::Report::Tree do
  subject(:report) { described_class.new }

  let(:klass) do
    Class.new do
      def self.to_s
        'TestClass'
      end
    end
  end

  before do
    report.add(:started, klass, :singleton, :perform, nil)
    report.add(:finished, klass, :singleton, :perform, 100.0)
    report.add(:started, klass, :singleton, :perform, nil)
    report.add(:started, klass, :instance, :call, nil)
    report.add(:finished, klass, :instance, :call, 50.0)
    report.add(:finished, klass, :singleton, :perform, 100.0)
  end

  describe '#to_a' do
    subject(:data) { report.to_a }

    let(:expected_report) do
      contain_exactly(match(
                        subject: 'TestClass.perform',
                        count: 2,
                        total_ms: 0.2,
                        total_percentage: 100.0,
                        total_self_ms: a_value_within(0.00001).of(0.15),
                        total_self_percentage: a_value_within(0.00001).of(75.0),
                        avg_ms: 0.1,
                        avg_self_ms: a_value_within(0.00001).of(0.075),
                        nested: contain_exactly(match(
                                                  subject: 'TestClass#call',
                                                  count: 1,
                                                  total_ms: 0.05,
                                                  total_percentage: 25.0,
                                                  total_self_ms: 0.05,
                                                  total_self_percentage: 25.0,
                                                  avg_ms: 0.05,
                                                  avg_self_ms: 0.05,
                                                  nested: []
                                                ))
                      ))
    end

    it 'returns expected report' do
      expect(data).to match expected_report
    end
  end

  describe '#to_s' do
    subject(:str_report) { report.to_s }

    it { is_expected.to be_a String }
  end
end
