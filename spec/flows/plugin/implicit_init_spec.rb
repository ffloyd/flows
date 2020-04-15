require 'spec_helper'

RSpec.describe Flows::Plugin::ImplicitInit do
  subject(:extended_class) do
    Class.new do
      extend Flows::Plugin::ImplicitInit

      def call
        object_id
      end
    end
  end

  describe '.call' do
    subject(:call) { extended_class.call }

    it 'works without exceptions' do
      expect { call }.not_to raise_error
    end

    context 'when called twice' do
      let!(:first_call_result) { extended_class.call }

      it 'reuses previously created instance' do
        expect(call).to eq first_call_result
      end
    end

    context 'when called with parametets' do
      subject(:call_with_params) { extended_class.call(*args, **kwargs, &block) }

      before do
        # force creation of memoized instance
        extended_class.call

        allow(instance).to receive(:call)
      end

      let(:instance) { extended_class.default_instance }

      let(:args) { [1, 2, 3] }
      let(:kwargs) { { a: 1, b: 2 } }
      let(:block) { proc {} }

      it 'all the parameters are passed to the instance call' do
        call_with_params

        expect(instance).to have_received(:call).with(*args, **kwargs, &block).once
      end
    end

    context 'when called on a host class and child class' do
      before do
        extended_class.call
        child_class.call
      end

      let(:child_class) { Class.new(extended_class) }
      let(:parent_instance) { extended_class.default_instance }
      let(:child_instance) { child_class.default_instance }

      it 'uses different instances for each class' do
        expect(parent_instance.object_id).not_to eq child_instance.object_id
      end
    end
  end
end
