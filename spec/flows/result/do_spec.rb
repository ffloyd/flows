require 'spec_helper'

RSpec.describe Flows::Result::Do do
  include Flows::Result::Helpers

  describe 'when all yieled values were ok' do
    let(:klass) do
      Class.new do
        extend Flows::Result::Do
        include Flows::Result::Helpers

        do_notation(:call_me)
        def call_me
          a = yield ok(value: 1)
          b = yield ok(value: 2)
          c = yield ok(value: 4)

          a[:value] + b[:value] + c[:value]
        end
      end
    end

    let(:instance) { klass.new }
    
    subject(:invoke) { instance.call_me }

    it 'yield unwraps its values' do
      expect(invoke).to eq(7)
    end
  end

  describe 'when yield gets err' do
    let(:klass) do
      Class.new do
        extend Flows::Result::Do
        include Flows::Result::Helpers

        do_notation(:call_me)
        def call_me(err_val, some_fn)
          yield err_val
          yield some_fn.call
        end
      end
    end

    let(:instance) { klass.new }
    
    subject(:invoke) { instance.call_me(error, success_fn) }

    let(:error) { err(msg: 'Something went wrong') }

    let(:success_fn) do
      double.tap do |dbl|
        allow(dbl).to receive(:call) { ok }
      end
    end

    it 'returns this err' do
      expect(invoke).to be error
    end

    it 'does not invoke subsequent lines in the method' do
      invoke

      expect(success_fn).not_to have_received(:call)
    end
  end

  describe 'unwrapping specific fields' do
    let(:klass) do
      Class.new do
        extend Flows::Result::Do
        include Flows::Result::Helpers

        do_notation(:call_me)
        def call_me
          yield :data, ok(data: :value, another_data: :another_value)
        end
      end
    end

    let(:instance) { klass.new }
    
    subject(:invoke) { instance.call_me }

    it 'returns only given field value' do
      expect(invoke).to eq [:value]
    end
  end

  describe 'when parent class has do-notation enabled' do
    subject(:invoke) { child.in_child }

    let(:parent_class) do
      Class.new do
        extend Flows::Result::Do
        include Flows::Result::Helpers
      end
    end
    
    let(:child_class) do
      Class.new(parent_class) do
        do_notation(:in_child)
        def in_child
          yield ok(alles: 'gut')
        end
      end
    end

    let(:child) { child_class.new }

    it 'child class also can use do-notation' do
      expect(invoke).to eq(alles: 'gut')
    end
  end
end
