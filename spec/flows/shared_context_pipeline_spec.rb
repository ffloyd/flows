require 'spec_helper'

RSpec.describe Flows::SharedContextPipeline do
  describe 'when no steps defined' do
    subject(:klass) do
      Class.new(described_class)
    end

    it 'raises error on initialization' do
      expect { klass.new }.to raise_error described_class::NoStepsError
    end
  end

  describe 'simple case with successful result' do
    subject(:calculation) { pipeline.call(a: 1, b: 2) }

    let(:pipeline) do
      Class.new(described_class) do
        step :calc_left_part
        step :calc_right_part
        step :calc_result

        def calc_left_part(a:, b:, **)
          ok(left: a + b)
        end

        def calc_right_part(a:, b:, **)
          ok(right: a - b)
        end

        def calc_result(left:, right:, **)
          ok(:last_step_status, result: left * right)
        end
      end
    end

    let(:expected_final_context) do
      {
        a: 1,
        b: 2,
        left: 3,
        right: -1,
        result: -3
      }
    end

    it 'returns successful result' do
      expect(calculation).to be_ok
    end

    it 'uses last executed step status' do
      expect(calculation.status).to eq :last_step_status
    end

    it 'returns full execution context' do
      expect(calculation.unwrap).to eq expected_final_context
    end
  end

  describe 'simple case with failure result' do
    subject(:calculation) { pipeline.call(a: 1, b: 2) }

    let(:pipeline) do
      Class.new(described_class) do
        step :fail_please
        step :useless

        def fail_please(**)
          err(:i_am_failed, from: :failed)
        end

        def useless(**)
          ok(:i_am_useless)
        end
      end
    end

    it 'returns failure result' do
      expect(calculation).to be_err
    end

    it 'uses last executed step status' do
      expect(calculation.status).to eq :i_am_failed
    end

    it 'returns full execution context' do
      expect(calculation.error).to eq(
        a: 1,
        b: 2,
        from: :failed
      )
    end
  end

  describe 'simple case with mutation steps successful result' do
    subject(:calculation) { pipeline.call(a: 1, b: 2) }

    let(:pipeline) do
      Class.new(described_class) do
        mut_step :calc_left_part
        mut_step :calc_right_part
        mut_step :calc_result

        def calc_left_part(ctx)
          ctx[:left] = ctx[:a] + ctx[:b]
        end

        def calc_right_part(ctx)
          ctx[:right] = ctx[:a] - ctx[:b]
        end

        def calc_result(ctx)
          ctx[:result] = ctx[:left] * ctx[:right]

          ok(:last_step_status)
        end
      end
    end

    let(:expected_final_context) do
      {
        a: 1,
        b: 2,
        left: 3,
        right: -1,
        result: -3
      }
    end

    it 'returns successful result' do
      expect(calculation).to be_ok
    end

    it 'uses last executed step status' do
      expect(calculation.status).to eq :last_step_status
    end

    it 'returns full execution context' do
      expect(calculation.unwrap).to eq expected_final_context
    end
  end
end
