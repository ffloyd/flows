RSpec.describe Flows::Router do
  RSpec.shared_examples 'router tests' do
    context 'when input is `:symbol`' do
      let(:input) { :symbol }

      it { is_expected.to eq :route_for_symbol_value }
    end

    context 'when input is `10`' do
      let(:input) { 10 }

      it { is_expected.to eq :route_for_integers }
    end

    context 'when input is `:other_symbol`' do
      let(:input) { :other_symbol }

      it { is_expected.to eq :route_for_other_symbols }
    end

    context 'when unexpected input `nil`' do
      let(:input) { nil }

      it { expect { invoke }.to raise_error Flows::Error }
    end
  end

  describe 'case equality based routing' do
    subject(:invoke) { router.call(input, context: {}) }

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
    subject(:invoke) { router.call(input, context: {}) }

    let(:router) do
      described_class.new(
        ->(x) { x == :symbol } => :route_for_symbol_value,
        ->(x) { x.is_a?(Integer) } => :route_for_integers,
        ->(x) { x.is_a?(Symbol) } => :route_for_other_symbols
      )
    end

    include_examples 'router tests'
  end

  describe 'use data from context using preprocessor' do
    subject(:invoke) { router.call(input, context: context) }

    let(:router) do
      described_class.new({
                            context_used: :context_used,
                            input: :context_not_used
                          }, preprocessor: preprocessor)
    end

    let(:preprocessor) do
      lambda do |input, context|
        if context == 'use me'
          :context_used
        else
          input
        end
      end
    end

    let(:input) { :input }
    let(:context) { 'use me' }

    it 'uses context' do
      expect(invoke).to eq :context_used
    end
  end
end
