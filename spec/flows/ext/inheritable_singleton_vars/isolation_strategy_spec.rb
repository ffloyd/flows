require 'spec_helper'

RSpec.describe Flows::Ext::InheritableSingletonVars::IsolationStrategy do
  describe('when 3 classes in an inheritance chain and each has a controlled variable and ' \
           'each changes inherited variables after definition') do
    let(:base_class) do
      Class.new do
        Flows::Ext::InheritableSingletonVars::IsolationStrategy.call(
          self,
          '@base' => -> { [] }
        )
      end
    end

    let(:middle_class) do
      Class.new(base_class) do
        Flows::Ext::InheritableSingletonVars::IsolationStrategy.call(
          self,
          '@middle' => -> { [] }
        )
      end
    end

    let(:last_class) do
      Class.new(middle_class) do
        Flows::Ext::InheritableSingletonVars::IsolationStrategy.call(
          self,
          '@last' => -> { [] }
        )
      end
    end

    before do
      base_class
      base_class.instance_variable_get(:@base) << 'base'

      middle_class
      middle_class.instance_variable_get(:@base) << 'middle'
      middle_class.instance_variable_get(:@middle) << 'middle'

      last_class
      last_class.instance_variable_get(:@base) << 'last'
      last_class.instance_variable_get(:@middle) << 'last'
      last_class.instance_variable_get(:@last) << 'last'
    end

    context 'when we look into the base class' do
      it 'has correct value of @base' do
        expect(base_class.instance_variable_get(:@base)).to eq ['base']
      end

      it 'has no value for @middle' do
        expect(base_class.instance_variable_get(:@middle)).to be_nil
      end

      it 'has no value for @last' do
        expect(base_class.instance_variable_get(:@last)).to be_nil
      end
    end

    context 'when we look into the middle class' do
      it 'has correct value of @base' do
        expect(middle_class.instance_variable_get(:@base)).to eq ['middle']
      end

      it 'has correct value for @middle' do
        expect(middle_class.instance_variable_get(:@middle)).to eq ['middle']
      end

      it 'has no value for @last' do
        expect(middle_class.instance_variable_get(:@last)).to be_nil
      end
    end

    context 'when we look into the last class' do
      it 'has correct value of @base' do
        expect(last_class.instance_variable_get(:@base)).to eq ['last']
      end

      it 'has correct value for @middle' do
        expect(last_class.instance_variable_get(:@middle)).to eq ['last']
      end

      it 'has correct value for @last' do
        expect(last_class.instance_variable_get(:@last)).to eq ['last']
      end
    end
  end
end
