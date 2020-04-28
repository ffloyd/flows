require 'spec_helper'

RSpec.describe Flows::Util::PrependToClass do
  let(:klass) do
    Class.new do
      attr_reader :greetings

      def initialize
        @greetings = 'Hello!'
      end
    end
  end

  let(:module_to_prepend) do
    Module.new do
    end
  end

  let(:prepender_mod) do
    described_class.make_module do
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

  let(:patched_mod) do
    Module.new { attr_reader :data }.tap do |mod|
      mod.include prepender_mod
    end
  end

  shared_examples 'preserves all the initializations' do
    it 'preserves original initialization' do
      expect(instance.greetings).to eq 'Hello!'
    end

    it 'preserves prepended initialization' do
      expect(instance.data).to eq 'DATA'
    end
  end

  context 'when patched module included into class' do
    subject(:instance) { klass.new(data: 'DATA') }

    before { klass.include patched_mod }

    it_behaves_like 'preserves all the initializations'
  end

  context 'when patched module included into module then into class' do
    subject(:instance) { klass.new(data: 'DATA') }

    before { klass.include middle_module }

    let(:middle_module) do
      Module.new.tap { |mod| mod.include patched_mod }
    end

    it_behaves_like 'preserves all the initializations'
  end
end
