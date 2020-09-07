require 'spec_helper'

RSpec.describe Flows::Plugin::DependencyInjector do
  context 'with no dependencies' do
    subject(:klass) do
      Class.new do
        include Flows::Plugin::DependencyInjector
      end
    end

    it 'raises error when we try to inject dependency' do
      expect { klass.new(dependencies: { a: 1 }) }.to raise_error described_class::UnexpectedDependencyError
    end

    it 'creates an instance when no dependencies provided' do
      expect(klass.new).to be_a klass
    end
  end

  context 'with optional dependency' do
    subject(:klass) do
      Class.new do
        include Flows::Plugin::DependencyInjector

        dependency :test, default: 'default_val'
      end
    end

    it 'sets default value if initialized without a dependency' do
      expect(klass.new.test).to eq 'default_val'
    end

    it 'sets provided value if intialized with a dependency' do
      value = klass.new(dependencies: {
                          test: 'injected_val'
                        }).test

      expect(value).to eq 'injected_val'
    end
  end

  context 'with required dependency' do
    subject(:klass) do
      Class.new do
        include Flows::Plugin::DependencyInjector

        dependency :test, required: true
      end
    end

    it 'raises error if dependency is not provided' do
      expect { klass.new }.to raise_error described_class::MissingDependencyError
    end

    it 'sets provided value if intialized with a dependency' do
      value = klass.new(dependencies: {
                          test: 'injected_val'
                        }).test

      expect(value).to eq 'injected_val'
    end
  end

  context 'with typed dependency' do
    subject(:klass) do
      Class.new do
        include Flows::Plugin::DependencyInjector

        dependency :test, required: true, type: String
      end
    end

    it 'raises error if type mistmatch' do
      expect do
        klass.new(dependencies: { test: 1 })
      end.to raise_error described_class::UnexpectedDependencyTypeError
    end

    it 'sets provided value if intialized with a dependency' do
      value = klass.new(dependencies: {
                          test: 'injected_val'
                        }).test

      expect(value).to eq 'injected_val'
    end
  end

  context 'with already existing initializer' do
    subject(:instance) do
      klass.new(
        data: 'data',
        dependencies: {
          test: 'test'
        }
      )
    end

    let(:klass) do
      Class.new do
        include Flows::Plugin::DependencyInjector

        dependency :test, required: true

        attr_reader :data

        def initialize(data:)
          @data = data
        end
      end
    end

    it 'preserves original initializer' do
      expect(instance.data).to eq 'data'
    end

    it 'sets the dependency' do
      expect(instance.test).to eq 'test'
    end
  end

  context 'with inheritance and initializers' do
    subject(:child_instance) do
      child_class.new(
        parent_data: 'parent',
        child_data: 'child',
        dependencies: {
          parent_dep: 'parent_dep',
          child_dep: 'child_dep'
        }
      )
    end

    let(:parent_class) do
      Class.new do
        include Flows::Plugin::DependencyInjector

        dependency :parent_dep, required: true

        attr_reader :parent_data

        def initialize(parent_data:)
          @parent_data = parent_data
        end
      end
    end

    let(:child_class) do
      Class.new(parent_class) do
        dependency :child_dep, required: true

        attr_reader :child_data

        def initialize(child_data:, **rest)
          @child_data = child_data

          super(**rest)
        end
      end
    end

    it 'preserves parent initialization' do
      expect(child_instance.parent_data).to eq 'parent'
    end

    it 'preserves child initialization' do
      expect(child_instance.child_data).to eq 'child'
    end

    it 'sets parent dependency' do
      expect(child_instance.parent_dep).to eq 'parent_dep'
    end

    it 'sets child dependency' do
      expect(child_instance.child_dep).to eq 'child_dep'
    end
  end

  context 'when included into module and module included into class' do
    subject(:instance) do
      klass.new('data', dependencies: {
                  test: 'test'
                })
    end

    let(:mod) do
      Module.new do
        include Flows::Plugin::DependencyInjector

        dependency :test, required: true
      end
    end

    let(:klass) do
      result = Class.new do
        attr_reader :data

        def initialize(data)
          @data = data
        end
      end

      result.tap { |k| k.include(mod) }
    end

    it 'sets a dependency' do
      expect(instance.test).to eq 'test'
    end

    it 'uses original initializer' do
      expect(instance.data).to eq 'data'
    end
  end

  context 'when no default provided for an optional dependency' do
    subject(:klass) do
      Class.new do
        include Flows::Plugin::DependencyInjector

        dependency :test
      end
    end

    it do
      expect { klass }.to raise_error described_class::MissingDependencyDefaultError
    end
  end

  context 'when included twice in inheritance chain + required dependency' do
    subject(:klass) do
      Class.new(parent_class) do
        include Flows::Plugin::DependencyInjector
      end
    end

    let(:parent_class) do
      Class.new do
        include Flows::Plugin::DependencyInjector

        dependency :test, required: true
      end
    end

    it 'raises error if dependency is not provided' do
      expect { klass.new }.to raise_error described_class::MissingDependencyError
    end

    it 'sets provided value if intialized with a dependency' do
      value = klass.new(dependencies: {
                          test: 'injected_val'
                        }).test

      expect(value).to eq 'injected_val'
    end
  end
end
