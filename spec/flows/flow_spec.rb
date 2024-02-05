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
        Flows::Flow::Node.new(
          body: ->(x) { x + 1 },
          router: Flows::Flow::Router::Custom.new(
            Integer => :mult_by_two
          )
        )
      end

      let(:node_mult_by_two) do
        Flows::Flow::Node.new(
          body: ->(x) { x * 2 },
          router: Flows::Flow::Router::Custom.new(
            Integer => :end
          )
        )
      end

      let(:input) { 10 }
      let(:context) { {} }

      it 'returns correct result' do
        expect(call).to eq 22
      end
    end

    context 'with simple three-node flow and branching' do
      let(:flow) do
        # it's example from the documentation
        described_class.new(
          start_node: :sum_list,
          node_map: {
            sum_list: Flows::Flow::Node.new(
              body: ->(list) { list.sum },
              router: Flows::Flow::Router::Custom.new(
                ->(x) { x > 10 } => :print_big,
                ->(x) { x <= 10 } => :print_small
              )
            ),
            print_big: Flows::Flow::Node.new(
              body: ->(_) { 'Big' },
              router: Flows::Flow::Router::Custom.new(
                String => :end
              )
            ),
            print_small: Flows::Flow::Node.new(
              body: ->(_) { 'Small' },
              router: Flows::Flow::Router::Custom.new(
                String => :end
              )
            )
          }
        )
      end

      it 'works in case of the first possible branch' do
        expect(flow.call([1, 2], context: {})).to eq 'Small'
      end

      it 'works in case of the second possible branch' do
        expect(flow.call([10, 20], context: {})).to eq 'Big'
      end
    end
  end

  describe 'routing integrity check (invalid start node)' do
    subject(:init) do
      described_class.new(
        start_node: :first,
        node_map: {}
      )
    end

    it 'raises error when first step is not defined' do
      expect { init }.to raise_error described_class::InvalidFirstNodeError
    end
  end

  describe 'routing integrity check (invalid node router destinations)' do
    subject(:init) do
      described_class.new(
        start_node: :first,
        node_map: {
          first: Flows::Flow::Node.new(
            body: ->(_) {},
            router: Flows::Flow::Router::Custom.new(
              a: :b
            )
          )
        }
      )
    end

    it 'raises error when first step is not defined' do
      expect { init }.to raise_error described_class::InvalidNodeRouteError
    end
  end
end
