require 'spec_helper'

RSpec.describe Flows::Ext::PrependToClass do
  shared_examples 'preserves all the initializations' do
    it 'preserves original initialization' do
      expect(instance.greetings).to eq 'Hello!'
    end

    it 'preserves prepended initialization' do
      expect(instance.data).to eq 'DATA'
    end
  end

  let(:klass) do
    Class.new do
      attr_reader :greetings

      def initialize
        @greetings = 'Hello!'
      end
    end
  end

  let(:patched_module) do
    Module.new do
      attr_reader :data

      Flows::Ext::PrependToClass.call(self) do
        def initialize(*args, **kwargs, &block)
          @data = kwargs[:data]

          filtered_kwargs = kwargs.reject { |key, _| key == :data }

          if filtered_kwargs.empty? # https://bugs.ruby-lang.org/issues/14415
            super(*args, &block)
          else
            super(*args, **filtered_kwargs, &block)
          end
        end
      end
    end
  end

  context 'when patched module included into class' do
    subject(:instance) { klass.new(data: 'DATA') }

    before { klass.include patched_module }

    it_behaves_like 'preserves all the initializations'
  end

  context 'when patched module included into module then into class' do
    subject(:instance) { klass.new(data: 'DATA') }

    before { klass.include middle_module }

    let(:middle_module) do
      Module.new.tap { |mod| mod.include patched_module }
    end

    it_behaves_like 'preserves all the initializations'
  end
end
