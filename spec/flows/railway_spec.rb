require 'spec_helper'

RSpec.describe Flows::Railway do
  include ::Flows::Result::Helpers

  describe 'without steps' do
    subject(:build) { railway_class.new }

    let(:railway_class) do
      Class.new do
        include Flows::Railway
      end
    end

    it { expect { build }.to raise_error Flows::Railway::NoStepsError }
  end

  describe 'with steps defined by methods' do
    subject(:railway) { railway_class.new }

    let(:railway_class) do
      Class.new do
        include Flows::Railway

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
      Class.new do
        include Flows::Railway

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
      Class.new do
        include Flows::Railway

        step :hello
      end
    end

    it { expect(invoke).to be_ok }

    it 'returns correct data' do
      expect(invoke.unwrap).to eq(arg: :value)
    end
  end
end
