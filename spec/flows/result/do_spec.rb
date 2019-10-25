require 'spec_helper'

RSpec.describe Flows::Result::Do do
  include Flows::Result::Helpers

  let(:example) { example_class.new }

  let(:example_class) do
    Class.new do
      extend Flows::Result::Do

      do_for(:simple_unwrap)
      def simple_unwrap(first, last)
        yield first.call
        yield last.call
      end

      do_for(:matched_unwrap)
      def matched_unwrap(fun, *fields)
        yield(*fields, fun.call)
      end
    end
  end

  describe 'unwrapping successful result' do
    subject(:invoke) do
      example.simple_unwrap(-> { ok(first: :value) }, -> { ok(second: :value) })
    end

    it 'works' do
      expect(invoke).to eq(second: :value)
    end
  end

  describe 'instant return on failure result' do
    subject(:invoke) do
      example.simple_unwrap(-> { first_result }, -> { second_op.call })
    end

    let(:first_result) { err(i_am: :error) }

    let(:second_op) do
      double.tap do |dbl|
        allow(dbl).to receive(:call) { ok }
      end
    end

    it 'returns first result' do
      expect(invoke).to eq first_result
    end

    it 'does not invoke subsequent ops' do
      invoke

      expect(second_op).not_to have_received(:call)
    end
  end

  describe 'unwrapping specific fields' do
    subject(:invoke) do
      example.matched_unwrap(-> { ok(data: :value) }, :data)
    end

    it 'returns only given field value' do
      expect(invoke).to eq [:value]
    end
  end

  describe 'inheritance support' do
    subject(:invoke) { child.in_child(-> { ok }, -> { ok(all: 'good') }) }

    let(:child_class) do
      Class.new(example_class) do
        do_for(:in_child)
        def in_child(first, last)
          yield first.call
          yield last.call
        end
      end
    end

    let(:child) { child_class.new }

    it 'works' do
      expect(invoke).to eq(all: 'good')
    end
  end
end
