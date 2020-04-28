require 'spec_helper'

RSpec.describe Flows::Flow::Router::Custom do
  include_context 'with helpers'

  describe '.call' do
    subject(:call) { router.call(output) }

    let(:output) { double }

    let(:predicate) { proc_double true }

    context 'when no preprocessor specified' do
      let(:router) do
        described_class.new(
          predicate => :next_route
        )
      end

      it 'calls predicate with output' do
        call

        expect(predicate).to have_received(:===).with(output)
      end

      it 'returns route' do
        expect(call).to eq :next_route
      end
    end

    context 'when several predicates matches' do
      let(:router) do
        described_class.new(
          predicate => :first_route,
          predicate.clone => :second_route,
          predicate.clone => :third_route
        )
      end

      it 'returns first matched route' do
        expect(call).to eq :first_route
      end
    end

    context 'when case equality used instead of predicates' do
      let(:router) do
        described_class.new(
          :aaa => :first_route,
          :bbb => :second_route,
          output => :third_route
        )
      end

      it 'returns correct route' do
        expect(call).to eq :third_route
      end
    end

    context 'when no route matched' do
      let(:router) { described_class.new(no_match: :route) }

      it 'raises Flows::Error' do
        expect { call }.to raise_error Flows::Flow::Router::NoRouteError
      end
    end
  end

  describe '#destinations' do
    subject(:destinations) { router.destinations }

    let(:router) { described_class.new(x: :y, a: :b) }

    it { is_expected.to eq %i[y b] }
  end
end
