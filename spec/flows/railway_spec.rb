require 'spec_helper'

RSpec.describe Flows::Railway do
  include ::Flows::Result::Helpers

  describe 'without steps' do
    subject(:build) { railway_class.new }

    let(:railway_class) do
      Class.new(described_class)
    end

    it { expect { build }.to raise_error described_class::NoStepsError }
  end

  describe 'with steps defined by methods' do
    subject(:railway) { railway_class.new }

    let(:railway_class) do
      Class.new(described_class) do
        step :sum
        step :square

        def sum(arg1:, arg2:)
          return err(invalid_argument: arg1) unless arg1.is_a?(Numeric)
          return err(invalid_argument: arg2) unless arg2.is_a?(Numeric)

          ok(sum: arg1 + arg2)
        end

        def square(sum:)
          ok(square: sum * sum)
        end
      end
    end

    context 'with correct arguments' do
      subject(:invoke) { railway.call(arg1: 2, arg2: 3) }

      it { expect(invoke).to be_ok }

      it 'returns correct result' do
        expect(invoke.unwrap).to eq(square: 25)
      end
    end

    context 'with incorrect arguments' do
      subject(:invoke) { railway.call(arg1: '2', arg2: '3') }

      it { expect(invoke).to be_err }

      it 'returns failure result' do
        expect(invoke.error).to eq(invalid_argument: '2')
      end
    end
  end

  describe 'with steps defined by lambdas' do
    subject(:invoke) { railway_class.new.call(arg: :value) }

    let(:railway_class) do
      Class.new(described_class) do
        step :hello, ->(**data) { ok(**data) }
      end
    end

    it { expect(invoke).to be_ok }

    it 'returns correct data' do
      expect(invoke.unwrap).to eq(arg: :value)
    end
  end

  describe 'with steps provides by deps' do
    subject(:invoke) do
      railway_class.new(deps: {
                          hello: ->(**data) { ok(**data) }
                        }).call(arg: :value)
    end

    let(:railway_class) do
      Class.new(described_class) do
        step :hello
      end
    end

    it { expect(invoke).to be_ok }

    it 'returns correct data' do
      expect(invoke.unwrap).to eq(arg: :value)
    end
  end

  describe 'inheritance support' do
    subject(:invoke_parent) { base_class.new.call }

    let(:base_class) do
      Class.new(described_class) do
        step :do_job

        def do_job(**)
          ok(:parent)
        end
      end
    end

    context 'when child class empty' do
      subject(:invoke) { railway_class.new.call }

      let(:railway_class) do
        Class.new(base_class)
      end

      it 'child works' do
        expect(invoke.status).to eq :parent
      end

      it 'parent works' do
        expect(invoke_parent.status).to eq :parent
      end
    end

    context 'when child class redefines step using method' do
      subject(:invoke) { railway_class.new.call }

      let(:railway_class) do
        Class.new(base_class) do
          def do_job(**)
            ok(:child)
          end
        end
      end

      it 'child works' do
        expect(invoke.status).to eq :child
      end

      it 'parent works' do
        expect(invoke_parent.status).to eq :parent
      end
    end

    context 'when child class redefines step using deps' do
      subject(:invoke) do
        railway_class.new(deps: {
                            do_job: ->(**) { ok(:child) }
                          }).call
      end

      let(:railway_class) do
        Class.new(base_class)
      end

      it 'child works' do
        expect(invoke.status).to eq :child
      end

      it 'parent works' do
        expect(invoke_parent.status).to eq :parent
      end
    end
  end

  describe 'implicit building' do
    subject(:base_class) do
      Class.new(described_class) do
        step :do_job

        def do_job(**)
          ok(data: 'ok')
        end
      end
    end

    it_behaves_like 'has implicit building'
  end
end
