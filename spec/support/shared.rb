# expects `let(:contract)` to be defined
RSpec.shared_examples 'Flows::Contract with valid value' do |value:, after_transform: value|
  describe '#check' do
    subject(:check) { contract.check(value) }

    it { is_expected.to be_ok }

    it 'returns `true` as a result data' do
      expect(check.unwrap).to eq true
    end
  end

  describe '#check!' do
    subject(:check) { contract.check!(value) }

    it { is_expected.to eq true }
  end

  describe '#transform' do
    subject(:transform) { contract.transform(value) }

    it { is_expected.to be_ok }

    it 'returns object after contract transform' do
      expect(transform.unwrap).to eq after_transform
    end
  end

  describe '#transform!' do
    subject(:transform) { contract.transform!(value) }

    it { is_expected.to eq after_transform }
  end

  describe '#===' do
    subject(:case_eq) { contract === value } # rubocop:disable Style/CaseEquality

    it { is_expected.to eq true }
  end

  describe '#to_proc' do
    subject(:result) { proc_check.call(value) }

    let(:proc_check) { contract.to_proc }

    it { is_expected.to eq true }
  end

  describe 'first transform law: "transformed value MUST match the contract"' do
    subject(:check) { contract.check!(after_transform) }

    it 'is met' do
      expect(check).to eq true
    end
  end

  describe 'second transform law: "tranformation of transformed value MUST has no effect"' do
    subject(:second_transform) { contract.transform!(after_transform) }

    it 'is met' do
      expect(second_transform).to eq after_transform
    end
  end
end

# expects `let(:contract)` to be defined
RSpec.shared_examples 'Flows::Contract with invalid value' do |value:, error_message: nil|
  describe '#check' do
    subject(:check) { contract.check(value) }

    it { is_expected.to be_err }

    if error_message
      it 'returns error message' do
        expect(check.error).to eq error_message
      end
    else
      it 'returns error message as String' do
        expect(check.error).to be_a String
      end
    end
  end

  describe '#check!' do
    subject(:check) { contract.check!(value) }

    it { expect { check }.to raise_error ::Flows::Contract::Error }
  end

  describe '#transform' do
    subject(:transform) { contract.transform(value) }

    it { is_expected.to be_err }

    if error_message
      it 'returns result object with expected error text after contract transform' do
        expect(transform.error).to eq error_message
      end
    else
      it 'returns result object after contract transform' do
        expect(transform.error).to be_a String
      end
    end
  end

  describe '#transform!' do
    subject(:transform) { contract.transform!(value) }

    it { expect { transform }.to raise_error ::Flows::Contract::Error }
  end

  describe '#===' do
    subject(:case_eq) { contract === value } # rubocop:disable Style/CaseEquality

    it { is_expected.to eq false }
  end

  describe '#to_proc' do
    subject(:result) { proc_check.call(value) }

    let(:proc_check) { contract.to_proc }

    it { is_expected.to eq false }
  end
end
