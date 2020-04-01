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

  describe 'simple case with mutation steps and successful result' do
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

  describe 'simple case with mutation steps and failure result' do
    subject(:calculation) { pipeline.call(a: 1, b: 2) }

    let(:pipeline) do
      Class.new(described_class) do
        mut_step :make_failure
        mut_step :not_executed

        def make_failure(ctx)
          ctx[:failure] = :made
          false
        end

        def not_executed(ctx)
          ctx[:executed] = :somehow
        end
      end
    end

    let(:expected_final_context) do
      {
        a: 1,
        b: 2,
        failure: :made
      }
    end

    it 'returns failure result' do
      expect(calculation).to be_err
    end

    it 'uses last executed step status' do
      expect(calculation.status).to eq :err
    end

    it 'returns full execution context' do
      expect(calculation.error).to eq expected_final_context
    end
  end

  describe 'simple case with step with custom routes' do
    subject(:result) { klass.call(input: input) }

    let(:klass) do
      Class.new(described_class) do
        step :decider, routes(
          match_ok(:first) => :route_first,
          match_ok(:second) => :route_second,
          match_err => :end
        )

        step :route_first, routes(match_ok => :end)
        step :route_second

        def decider(input:)
          return err unless %i[first second].include?(input)

          ok(input)
        end

        def route_first(**)
          ok(:first)
        end

        def route_second(**)
          ok(:second)
        end
      end
    end

    context 'when first route used' do
      let(:input) { :first }

      it { is_expected.to be_ok }

      it 'has expected status' do
        expect(result.status).to eq :first
      end
    end

    context 'when second route used' do
      let(:input) { :second }

      it { is_expected.to be_ok }

      it 'has expected status' do
        expect(result.status).to eq :second
      end
    end

    context 'when failure happened' do
      let(:input) { :other }

      it { is_expected.to be_err }

      it 'has expected status' do
        expect(result.status).to eq :err
      end
    end
  end

  describe 'simple case with track' do
    subject(:result) { klass.call(input: input) }

    let(:klass) do
      Class.new(described_class) do
        step :decider, routes(
          match_ok(:isolated) => :isolated,
          match_ok(:to_main) => :with_return_to_main,
          match_ok => :finish,
          match_err => :end
        )

        track :isolated do
          step :isolated_step
        end

        track :with_return_to_main do
          step :to_main, routes(
            match_ok => :finish,
            match_err => :end
          )
        end

        step :finish

        def decider(input:)
          ok(input)
        end

        def isolated_step(**)
          ok(:isolated)
        end

        def to_main(**)
          ok(was_here: :with_return_to_main_track)
        end

        def finish(**)
          ok(:finish)
        end
      end
    end

    context 'when isolated track activated' do
      let(:input) { :isolated }

      it { is_expected.to be_ok }

      it 'has expected status' do
        expect(result.status).to eq :isolated
      end

      it 'has expected payload' do
        expect(result.unwrap).to eq(
          input: :isolated
        )
      end
    end

    context 'when track with return to main track activated' do
      let(:input) { :to_main }

      it { is_expected.to be_ok }

      it 'has expected status' do
        expect(result.status).to eq :finish
      end

      it 'has expected payload' do
        expect(result.unwrap).to eq(
          input: :to_main,
          was_here: :with_return_to_main_track
        )
      end
    end

    context 'when no track activated' do
      let(:input) { :blablabla }

      it { is_expected.to be_ok }

      it 'has expected status' do
        expect(result.status).to eq :finish
      end

      it 'has expected payload' do
        expect(result.unwrap).to eq(
          input: :blablabla
        )
      end
    end
  end

  describe 'before_all callback' do
    include_context 'with helpers'

    subject(:calculation) { klass.call(input: :data) }

    let(:klass) do
      result = Class.new(described_class) do
        step :hi

        def hi(**)
          ok
        end
      end

      result.before_all(&before_all_proc)

      result
    end

    let(:before_all_proc) do
      make_proc_double do |_, ctx|
        ctx.merge!(from: :callback)
      end
    end

    it 'executes callback' do
      calculation

      expect(before_all_proc).to have_received(:call).with(klass, instance_of(Hash))
    end

    it 'patches execution context' do
      expect(calculation.unwrap).to eq(
        input: :data,
        from: :callback
      )
    end
  end

  describe 'after_all callback' do
    include_context 'with helpers'

    subject(:calculation) { klass.call(input: :data) }

    let(:klass) do
      result = Class.new(described_class) do
        step :hi

        def hi(**)
          ok
        end
      end

      result.after_all(&after_all_proc)

      result
    end

    let(:after_all_proc) do
      make_proc_double do |_, _|
        Flows::Result::Ok.new({}, status: :substituted)
      end
    end

    it 'executes callback' do
      calculation

      expect(after_all_proc).to have_received(:call).with(klass, Flows::Result::Ok.new(input: :data))
    end

    it 'substitutes result' do
      expect(calculation.status).to eq :substituted
    end
  end

  describe 'before_each callback' do
    include_context 'with helpers'

    subject(:calculation) { klass.call(input: :data) }

    let(:klass) do
      result = Class.new(described_class) do
        step :hi
        mut_step :hello

        def hi(**)
          ok(from_hi: :data)
        end

        def hello(**)
          true
        end
      end

      result.before_each(&before_each_proc)

      result
    end

    let(:before_each_proc) do
      make_proc_double do |_, step_name, context|
        context[step_name] = :was_here
      end
    end

    let(:expected_context) do
      {
        input: :data,
        from_hi: :data,
        hi: :was_here,
        hello: :was_here
      }
    end

    it 'executes callback' do # rubocop:disable RSpec/MultipleExpectations
      calculation

      expect(before_each_proc).to have_received(:call).with(klass, :hi, instance_of(Hash)).once.ordered
      expect(before_each_proc).to have_received(:call).with(klass, :hello, instance_of(Hash)).once.ordered
    end

    it 'modifies context' do
      expect(calculation.unwrap).to eq expected_context
    end
  end

  describe 'after_each callback' do
    include Flows::Result::Helpers
    include_context 'with helpers'

    subject(:calculation) { klass.call(input: :data) }

    let(:klass) do
      result = Class.new(described_class) do
        step :hi
        mut_step :hello

        def hi(**)
          ok(from_hi: :data)
        end

        def hello(**)
          true
        end
      end

      result.after_each(&after_each_proc)

      result
    end

    let(:after_each_proc) do
      make_proc_double do |_, step_name, context, _|
        context[step_name] = :was_here
      end
    end

    let(:expected_context) do
      {
        input: :data,
        from_hi: :data,
        hi: :was_here,
        hello: :was_here
      }
    end

    it 'executes callback' do # rubocop:disable RSpec/MultipleExpectations
      calculation

      expect(after_each_proc).to have_received(:call)
        .with(klass, :hi, instance_of(Hash), ok(from_hi: :data)).once.ordered
      expect(after_each_proc).to have_received(:call)
        .with(klass, :hello, instance_of(Hash), Flows::Result::Ok.new(nil)).once.ordered
    end

    it 'modifies context' do
      expect(calculation.unwrap).to eq expected_context
    end
  end
end
