RSpec.describe Flows::Router do
  RSpec.shared_examples 'router tests' do
    context 'when input is `:symbol`' do
      let(:data) { :symbol }

      it { is_expected.to eq :route_for_symbol_value }
    end

    context 'when input is `10`' do
      let(:data) { 10 }

      it { is_expected.to eq :route_for_integers }
    end

    context 'when input is `:other_symbol`' do
      let(:data) { :other_symbol }

      it { is_expected.to eq :route_for_other_symbols }
    end

    context 'when unexpected input `nil`' do
      let(:data) { nil }

      it { expect { invoke }.to raise_error Flows::Error }
    end
  end

  describe 'case equality based routing' do
    subject(:invoke) { router.call(data) }

    let(:router) do
      described_class.new(
        :symbol => :route_for_symbol_value,
        Integer => :route_for_integers,
        Symbol => :route_for_other_symbols
      )
    end

    include_examples 'router tests'
  end

  describe 'proc based routing' do
    subject(:invoke) { router.call(data) }

    let(:router) do
      described_class.new(
        ->(x) { x == :symbol } => :route_for_symbol_value,
        ->(x) { x.is_a?(Integer) } => :route_for_integers,
        ->(x) { x.is_a?(Symbol) } => :route_for_other_symbols
      )
    end

    include_examples 'router tests'
  end
end
