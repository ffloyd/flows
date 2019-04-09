require 'spec_helper'

RSpec.describe Flows::Flow do
  include_context 'with helpers'

  describe '.call' do
    subject(:call) { flow.call(input, context: context) }

    context 'with simple two-node flow' do
      let(:flow) do
        described_class.new(
          start_node: node_a.name,
          nodes: [node_a, node_b]
        )
      end

      let(:node_a) do
        Flows::Node.new(
          name: :plus_one,
          body: ->(x) { x + 1 },
          router: Flows::Router.new(
            Integer => :mult_two
          )
        )
      end

      let(:node_b) do
        Flows::Node.new(
          name: :mult_two,
          body: ->(x) { x * 2 },
          router: Flows::Router.new(
            Integer => :term
          )
        )
      end

      let(:input) { 10 }
      let(:context) { {} }

      it 'works' do
        expect(call).to eq 22
      end
    end
  end
end
