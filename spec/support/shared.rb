# expects `let(:type)` to be defined
RSpec.shared_examples 'Flows::Type with valid value' do |value:, after_cast: value|
  describe '#check' do
    subject(:check) { type.check(value) }

    it { is_expected.to be_ok }

    it 'returns `true` as a result data' do
      expect(check.unwrap).to eq true
    end
  end

  describe '#check!' do
    subject(:check) { type.check!(value) }

    it { is_expected.to eq true }
  end

  describe '#cast' do
    subject(:cast) { type.cast(value) }

    it { is_expected.to be_ok }

    it 'returns object after type cast' do
      expect(cast.unwrap).to eq after_cast
    end
  end

  describe '#cast!' do
    subject(:cast) { type.cast!(value) }

    it { is_expected.to eq after_cast }
  end

  describe '#===' do
    subject(:case_eq) { type === value } # rubocop:disable Style/CaseEquality

    it { is_expected.to eq true }
  end

  describe '#to_proc' do
    subject(:result) { proc_check.call(value) }

    let(:proc_check) { type.to_proc }

    it { is_expected.to eq true }
  end
end

# expects `let(:type)` to be defined
RSpec.shared_examples 'Flows::Type with invalid value' do |value:, error_message:|
  describe '#check' do
    subject(:check) { type.check(value) }

    it { is_expected.to be_err }

    it 'returns expected error message' do
      expect(check.error).to eq error_message
    end
  end

  describe '#check!' do
    subject(:check) { type.check!(value) }

    it { expect { check }.to raise_error ::Flows::Type::Error }
  end

  describe '#cast' do
    subject(:cast) { type.cast(value) }

    it { is_expected.to be_err }

    it 'returns object after type cast' do
      expect(cast.error).to eq error_message
    end
  end

  describe '#cast!' do
    subject(:cast) { type.cast!(value) }

    it { expect { cast }.to raise_error ::Flows::Type::Error }
  end

  describe '#===' do
    subject(:case_eq) { type === value } # rubocop:disable Style/CaseEquality

    it { is_expected.to eq false }
  end

  describe '#to_proc' do
    subject(:result) { proc_check.call(value) }

    let(:proc_check) { type.to_proc }

    it { is_expected.to eq false }
  end
end
