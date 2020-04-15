require 'spec_helper'

RSpec.describe Flows::Util::InheritableSingletonVars do
  describe 'all strategies can be used together' do
    before do
      base_class
      base_class.instance_variable_get(:@with_dup) << 'base'
      base_class.instance_variable_get(:@with_isolation) << 'base'

      child_class
      child_class.instance_variable_get(:@with_dup) << 'child'
      child_class.instance_variable_get(:@with_isolation) << 'child'
    end

    let(:base_class) do
      Class.new do
        Flows::Util::InheritableSingletonVars::DupStrategy.call(
          self,
          '@with_dup' => []
        )

        Flows::Util::InheritableSingletonVars::IsolationStrategy.call(
          self,
          '@with_isolation' => -> { [] }
        )
      end
    end

    let(:child_class) do
      Class.new(base_class)
    end

    it 'correctly sets DupStrategy variable on the base class' do
      expect(base_class.instance_variable_get(:@with_dup)).to eq ['base']
    end

    it 'correctly sets DupStrategy variable on the child class' do
      expect(child_class.instance_variable_get(:@with_dup)).to eq %w[base child]
    end

    it 'correctly sets IsolationStrategy variable on the base class' do
      expect(base_class.instance_variable_get(:@with_isolation)).to eq ['base']
    end

    it 'correctly sets IsolationStrategy variable on the child class' do
      expect(child_class.instance_variable_get(:@with_isolation)).to eq ['child']
    end
  end
end
