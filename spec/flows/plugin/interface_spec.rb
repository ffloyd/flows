require 'spec_helper'

RSpec.describe Flows::Plugin::Interface do
  describe 'empty interface' do
    subject(:child_class) do
      Class.new(parent_class)
    end

    let(:parent_class) do
      Class.new.tap do |klass|
        klass.extend described_class
      end
    end

    it 'allows creation of empty class' do
      expect { child_class.new }.not_to raise_error
    end
  end

  describe 'simple interface' do
    context 'when required method defined' do
      subject(:child_class) do
        Class.new(parent_class) do
          def perform; end
        end
      end

      let(:parent_class) do
        Class.new.tap do |klass|
          klass.extend described_class
          klass.defmethod :perform
        end
      end

      it 'allows creation of a child class' do
        expect { child_class.new }.not_to raise_error
      end
    end

    context 'when required method missed' do
      subject(:child_class) do
        Class.new(parent_class)
      end

      let(:parent_class) do
        Class.new.tap do |klass|
          klass.extend described_class
          klass.defmethod :perform
        end
      end

      it 'raises an error' do
        expect { child_class.new }.to raise_error described_class::MissingMethodsError
      end
    end
  end

  describe 'composition of two interfaces', skip: 'not implemented yet' do
    let(:interface_module_one) do
      Module.new.tap do |mod|
        mod.extend described_class
        mod.defmethod :required_by_first
      end
    end

    let(:interface_module_two) do
      Module.new.tap do |mod|
        mod.extend described_class
        mod.defmethod :required_by_second
      end
    end

    let(:parent_class) do
      Class.new.tap do |klass|
        klass.include interface_module_one
        klass.include interface_module_two
      end
    end

    context 'when required method from first interface is missing' do
      subject(:child_class) do
        Class.new(parent_class) do
          def required_by_first; end
        end
      end

      it 'raises an error' do
        expect { child_class.new }.to raise_error described_class::MissingMethodsError
      end
    end

    context 'when required method from second interface is missing' do
      subject(:child_class) do
        Class.new(parent_class) do
          def required_by_second; end
        end
      end

      it 'raises an error' do
        expect { child_class.new }.to raise_error described_class::MissingMethodsError
      end
    end

    context 'when both interfaces are met' do
      subject(:child_class) do
        Class.new(parent_class) do
          def required_by_first; end

          def required_by_second; end
        end
      end

      it 'allows creation of a child class' do
        expect { child_class.new }.not_to raise_error
      end
    end
  end
end
