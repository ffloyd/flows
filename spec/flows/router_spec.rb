require 'spec_helper'

RSpec.describe Flows::Router do
  include_context 'with helpers'

  describe '.call' do
    subject(:call) { router.call(output, context: context, meta: meta) }

    let(:output) { double }
    let(:context) { double }
    let(:meta) { double }

    let(:predicate) { proc_double true }

    context 'when no preprocessor specified' do
      let(:router) do
        described_class.new(
          predicate => :next_route
        )
      end

      it 'calls predicate with output' do
        call

        expect(predicate).to have_received(:call).with(output)
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
          meta => :first_route,
          context => :second_route,
          output => :third_route
        )
      end

      it 'returns correct route' do
        expect(call).to eq :third_route
      end
    end

    context 'when preprocessor used' do
      let(:router) do
        described_class.new(routes, preprocessor: preprocessor)
      end

      let(:routes) do
        { preprocessor_result => :route }
      end

      let(:preprocessor_result) { double }

      let(:preprocessor) { proc_double preprocessor_result }

      it 'calls preprocessor with output, contexta and meta' do
        call

        expect(preprocessor).to have_received(:call).with(output, context, meta)
      end

      it 'uses preprocessor result as data for routing' do
        expect(call).to eq :route
      end
    end

    context 'when no route matched' do
      let(:router) { described_class.new(no_match: :route) }

      it 'raises Flows::Error' do
        expect { call }.to raise_error Flows::Error
      end
    end
  end
end
