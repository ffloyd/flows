# expects `let(:type)` to be defined
RSpec.shared_examples Flows::Type do |correct_value:, invalid_value:, extracted_value: correct_value, error_message:|
  describe '#check' do
    subject(:check) { type.check(value) }

    context 'with correct value' do
      let(:value) { correct_value }

      it { is_expected.to be_ok }

      it 'returns `true` as a result data' do
        expect(check.unwrap).to eq true
      end
    end

    context 'with invalid value' do
      let(:value) { invalid_value }

      it { is_expected.to be_err }

      it 'returns correct error message' do
        expect(check.error).to eq error_message
      end
    end
  end

  describe '#check!' do
    subject(:check) { type.check!(value) }

    context 'with correct value' do
      let(:value) { correct_value }

      it { is_expected.to eq true }
    end

    context 'with invalid value' do
      let(:value) { invalid_value }

      it 'raises error' do
        expect { check }.to raise_error ::Flows::Type::Error
      end
    end
  end

  describe '#===' do
    subject(:check) { type === value } # rubocop:disable Style/CaseEquality

    context 'with correct value' do
      let(:value) { correct_value }

      it { is_expected.to eq true }
    end

    context 'with invalid value' do
      let(:value) { invalid_value }

      it { is_expected.to eq false }
    end
  end

  describe '#cast' do
    subject(:cast) { type.cast(value) }

    context 'with correct value' do
      let(:value) { correct_value }

      it { is_expected.to be_ok }

      it 'returns extracted data' do
        expect(cast.unwrap).to eq extracted_value
      end
    end

    context 'with invalid value' do
      let(:value) { invalid_value }

      it { is_expected.to be_err }

      it 'returns correct error message' do
        expect(cast.error).to eq error_message
      end
    end
  end
end
