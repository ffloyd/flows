require 'spec_helper'

RSpec.describe Flows::Util::InheritableSingletonVars::DupStrategy do
  # expects `let(:base_class) {...}` definition in the parent context
  # with 2 variables `@array` and `@integer` and defaults `[]` and `3`.
  shared_examples 'expected' do
    let(:array_variable) { base_class.instance_variable_get(:@array) }
    let(:integer_variable) { base_class.instance_variable_get(:@integer) }

    it 'sets array variable default' do
      expect(array_variable).to eq []
    end

    it 'sets integer variable default' do
      expect(integer_variable).to eq 3
    end

    context 'when chid class created and when base class\' variablies are modified afterwards' do
      subject(:child_class) { Class.new(base_class) }

      before do
        # change values before child class definition
        array_variable << 'before copy'
        base_class.instance_variable_set(:@integer, 5)

        child_class # child class definition happens here

        child_array_variable << 'after copy'
        child_class.instance_variable_set(:@integer, 10)
      end

      let(:child_array_variable) { child_class.instance_variable_get(:@array) }
      let(:child_integer_variable) { child_class.instance_variable_get(:@integer) }

      it 'preserves array in the base class unmodyfied' do
        expect(array_variable).to eq ['before copy']
      end

      it 'saves array mofifications in the child class' do
        expect(child_array_variable).to eq ['before copy', 'after copy']
      end

      it 'preserves integer in the base class unmodyfied' do
        expect(integer_variable).to eq 5
      end

      it 'saves integer mofifications in the child class' do
        expect(child_integer_variable).to eq 10
      end
    end
  end

  describe 'when applied to base class' do
    subject(:base_class) do
      Class.new do
        include Flows::Util::InheritableSingletonVars::DupStrategy.make_module(
          '@array' => [],
          '@integer' => 3
        )
      end
    end

    it_behaves_like 'expected'
  end

  describe 'when applied twice in the base class' do
    subject(:base_class) do
      Class.new do
        include Flows::Util::InheritableSingletonVars::DupStrategy.make_module(
          '@array' => []
        )

        extend Flows::Util::InheritableSingletonVars::DupStrategy.make_module(
          '@integer' => 3
        )
      end
    end

    it_behaves_like 'expected'
  end

  describe('when applied to a module which included into module which included into class') do
    subject(:base_class) do
      Class.new.tap do |klass|
        klass.include middle_module
      end
    end

    let(:middle_module) do
      Module.new.tap { |mod| mod.include inner_module }
    end

    let(:inner_module) do
      Module.new.tap do |mod|
        mod.include described_class.make_module(
          '@array' => []
        )

        mod.include described_class.make_module(
          '@integer' => 3
        )
      end
    end

    it_behaves_like 'expected'
  end

  describe('when 3 classes in an inheritance chain and each has a controlled variable and ' \
           'each changes inherited variables') do
    let(:base_class) do
      Class.new do
        include Flows::Util::InheritableSingletonVars::DupStrategy.make_module(
          '@base' => ['base']
        )
      end
    end

    let(:middle_class) do
      Class.new(base_class) do
        include Flows::Util::InheritableSingletonVars::DupStrategy.make_module(
          '@middle' => ['middle']
        )
      end
    end

    let(:last_class) do
      Class.new(middle_class) do
        include Flows::Util::InheritableSingletonVars::DupStrategy.make_module(
          '@last' => ['last']
        )
      end
    end

    before do
      base_class

      middle_class
      middle_class.instance_variable_get(:@base) << 'middle'

      last_class
      last_class.instance_variable_get(:@base) << 'last'
      last_class.instance_variable_get(:@middle) << 'last'
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
        expect(middle_class.instance_variable_get(:@base)).to eq %w[base middle]
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
        expect(last_class.instance_variable_get(:@base)).to eq %w[base middle last]
      end

      it 'has correct value for @middle' do
        expect(last_class.instance_variable_get(:@middle)).to eq %w[middle last]
      end

      it 'has correct value for @last' do
        expect(last_class.instance_variable_get(:@last)).to eq ['last']
      end
    end
  end

  describe 'when parent class has updated variable and the same module included into child class' do
    let(:child_class) do
      Class.new(parent_class).tap { |klass| klass.include vars_module }
    end

    let(:parent_class) do
      Class.new.tap do |klass|
        klass.include vars_module

        klass.instance_variable_set(:@var, 10)
      end
    end

    let(:vars_module) do
      described_class.make_module(
        '@var' => 0
      )
    end

    let(:child_value) { child_class.instance_variable_get(:@var) }
    let(:parent_value) { parent_class.instance_variable_get(:@var) }

    it 'child class has an updated value' do
      expect(child_value).to eq 10
    end

    it 'parent class has an updated value' do
      expect(parent_value).to eq 10
    end
  end
end
