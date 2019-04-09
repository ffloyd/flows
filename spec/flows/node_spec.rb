require 'spec_helper'

RSpec.describe Flows::Node do
  include_context 'with helpers'

  describe '.call' do
    subject(:call) do
      node.call(input, context: context)
    end

    let(:input) { double }
    let(:context) { double }

    let(:name) { :node_name }

    let(:output) { double }
    let(:body) { proc_double output }

    let(:router) do
      Flows::Router.new(output => :next_route)
    end

    let(:meta) { { some: :meta } }

    let(:init_params) do
      {
        name: name,
        body: body,
        router: router,
        meta: meta
      }
    end

    context 'with simplest node' do
      let(:node) { described_class.new(init_params) }

      it 'returns output and next route' do
        expect(call).to eq [output, :next_route]
      end
    end

    context 'with defined preprocessor' do
      let(:node) do
        described_class.new(
          init_params.merge(preprocessor: preprocessor)
        )
      end

      let(:preprocessor_result) { double }
      let(:preprocessor) { proc_double preprocessor_result }

      it 'calls preprocessor with input, context and meta' do
        call

        expect(preprocessor).to have_received(:call).with(input, context, meta)
      end

      it 'uses preprocessor output as body input' do
        call

        expect(body).to have_received(:call).with(preprocessor_result)
      end
    end

    context 'with defined postprocessor' do
      let(:node) do
        described_class.new(
          init_params.merge(postprocessor: postprocessor)
        )
      end

      let(:router) { proc_double :next_route }

      let(:postprocessor_result) { double }
      let(:postprocessor) { proc_double postprocessor_result }

      it 'calls postprocessor with body output, context and meta' do
        call

        expect(postprocessor).to have_received(:call).with(output, context, meta)
      end

      it 'uses postprocessor output as router input' do
        call

        expect(router).to have_received(:call).with(postprocessor_result, context: context, meta: meta)
      end
    end
  end
end
