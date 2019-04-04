require 'spec_helper'

RSpec.describe Flows::Node do
  describe 'simplest node which should return `:output` as result and `:next_node` as route' do
    subject(:node) do
      described_class.new(
        :node,
        body: ->(_) { :output },
        router: {
          ->(_, _) { true } => :next_node
        }
      )
    end

    it 'has selected name' do
      expect(node.name).to eq :node
    end

    it 'returns `:output` as output and `:next_node` as route' do
      result = node.call(input: nil, context: {})

      expect(result).to eq %i[output next_node]
    end
  end

  describe 'node with comparsion routing based on lambdas' do
    subject(:node) do
      described_class.new(
        :node,
        body: ->(input) { input },
        router: {
          ->(output, _) { true if output > 10 } => :big,
          ->(output, _) { true if output > 0 } => :small
        }
      )
    end

    it 'when input is 100 routes to `:big`' do
      _, route = node.call(input: 100, context: {})

      expect(route).to eq :big
    end

    it 'when input is 2 routes to `:small`' do
      _, route = node.call(input: 2, context: {})

      expect(route).to eq :small
    end

    it 'when no route for given input raises an error' do
      expect do
        node.call(input: -10, context: {})
      end.to raise_error Flows::Error
    end
  end

  describe 'node with boolean routing based on case equality' do
    subject(:node) do
      described_class.new(
        :node,
        body: ->(input) { input },
        router: {
          true => :good,
          false => :bad
        }
      )
    end

    it 'when input is `true` routes to `:good`' do
      _, route = node.call(input: true, context: {})

      expect(route).to eq :good
    end

    it 'when input is `false` routes to `:bad`' do
      _, route = node.call(input: false, context: {})

      expect(route).to eq :bad
    end
  end
end
