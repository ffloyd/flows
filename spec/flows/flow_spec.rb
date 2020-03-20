require 'spec_helper'

RSpec.describe Flows::Flow do
  include_context 'with helpers'

  describe '.call' do
    subject(:call) { flow.call(input, context: context) }

    context 'with simple two-node flow' do
      let(:flow) do
        described_class.new(
          start_node: :plus_one,
          node_map: {
            plus_one: node_plus_one,
            mult_by_two: node_mult_by_two
          }
        )
      end

      let(:node_plus_one) do
        Flows::Node.new(
          body: ->(x) { x + 1 },
          router: Flows::Router.new(routes: {
                                      Integer => :mult_by_two
                                    })
        )
      end

      let(:node_mult_by_two) do
        Flows::Node.new(
          body: ->(x) { x * 2 },
          router: Flows::Router.new(routes: {
                                      Integer => :term
                                    })
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
