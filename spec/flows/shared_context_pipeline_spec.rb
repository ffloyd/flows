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
      make_proc_double do |_, ctx, meta|
        ctx[:from] = :callback
        meta[:from] = :callback_meta
      end
    end

    it 'executes callback' do
      calculation

      expect(before_all_proc).to have_received(:call).with(klass, instance_of(Hash), instance_of(Hash))
    end

    it 'patches execution context' do
      expect(calculation.unwrap).to eq(
        input: :data,
        from: :callback
      )
    end

    it 'patches meta' do
      expect(calculation.meta).to eq(
        from: :callback_meta
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

      result.after_all(&after_all_proc_1)
      result.after_all(&after_all_proc_2)

      result
    end

    let(:after_all_proc_1) do
      make_proc_double do |_, result, ctx, meta|
        ctx[:from] = :callback
        meta[:from] = :callback_meta

        result.unwrap[:first] = :callback
        result
      end
    end

    let(:after_all_proc_2) do
      make_proc_double do |_, _, ctx, meta|
        Flows::Result::Ok.new(ctx, status: :substituted, meta: meta)
      end
    end

    it 'executes 1st callback' do
      calculation

      expect(after_all_proc_1).to have_received(:call).with(
        klass, instance_of(Flows::Result::Ok), instance_of(Hash), instance_of(Hash)
      )
    end

    it 'executes 2nd callback' do
      calculation

      expect(after_all_proc_2).to have_received(:call).with(
        klass, instance_of(Flows::Result::Ok), instance_of(Hash), instance_of(Hash)
      )
    end

    it 'substitutes result' do
      expect(calculation.status).to eq :substituted
    end

    it 'patches execution context' do
      expect(calculation.unwrap).to eq(
        input: :data,
        first: :callback,
        from: :callback
      )
    end

    it 'patches meta' do
      expect(calculation.meta).to eq(
        from: :callback_meta
      )
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
      make_proc_double do |_, step_name, context, meta|
        context[step_name] = :was_here
        meta[step_name] = :was_here_meta
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

    let(:expected_meta) do
      {
        hi: :was_here_meta,
        hello: :was_here_meta
      }
    end

    it 'executes callback' do # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
      calculation

      expect(before_each_proc).to have_received(:call).with(
        klass, :hi, instance_of(Hash), instance_of(Hash)
      ).once.ordered

      expect(before_each_proc).to have_received(:call).with(
        klass, :hello, instance_of(Hash), instance_of(Hash)
      ).once.ordered
    end

    it 'modifies context' do
      expect(calculation.unwrap).to eq expected_context
    end

    it 'modifies meta' do
      expect(calculation.meta).to eq expected_meta
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
      make_proc_double do |_, step_name, _result, context, meta|
        context[step_name] = :was_here
        meta[step_name] = :was_here_meta
      end
    end

    let(:expected_context) do
      {
        hi: :was_here,
        from_hi: :data,
        hello: :was_here,
        input: :data
      }
    end

    let(:expected_meta) do
      {
        hi: :was_here_meta,
        hello: :was_here_meta
      }
    end

    it 'executes callback' do # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
      calculation

      expect(after_each_proc).to have_received(:call)
        .with(klass, :hi, ok(from_hi: :data), instance_of(Hash), instance_of(Hash))
        .once.ordered

      expect(after_each_proc).to have_received(:call)
        .with(klass, :hello, Flows::Result::Ok.new({}), instance_of(Hash), instance_of(Hash))
        .once.ordered
    end

    it 'modifies context' do
      expect(calculation.unwrap).to eq expected_context
    end

    it 'modifies meta' do
      expect(calculation.meta).to eq expected_meta
    end
  end

  describe 'wrap DSL (basic usage)' do
    include Flows::Result::Helpers
    include_context 'with helpers'

    subject(:calculation) { klass.call(input: :data) }

    let(:klass) do
      Class.new(described_class) do
        step :first
        wrap :my_wrap do
          step :inside_a
        end
        wrap :my_wrap do
          step :inside_b
        end

        def my_wrap(ctx, meta)
          ctx[:my_wrap] ||= []
          ctx[:my_wrap] << :executed

          meta[:my_wrap] ||= []
          meta[:my_wrap] << :executed

          result = yield

          ok(**result.unwrap.merge(result: :patched))
        end

        def first(**)
          ok(first_step: :executed)
        end

        def inside_a(**)
          ok(inside_a_step: :executed)
        end

        def inside_b(**)
          ok(inside_b_step: :executed)
        end
      end
    end

    let(:expected_context) do
      {
        input: :data,
        first_step: :executed,
        inside_a_step: :executed,
        inside_b_step: :executed,
        my_wrap: %i[executed executed],
        result: :patched
      }
    end

    let(:expected_meta) do
      {
        my_wrap: %i[executed executed]
      }
    end

    it 'returns expected context' do
      expect(calculation.unwrap).to eq expected_context
    end

    it 'returns expected meta' do
      expect(calculation.meta).to eq expected_meta
    end
  end

  describe 'wrap DSL (valid routing)' do
    include Flows::Result::Helpers
    include_context 'with helpers'

    subject(:calculation) { klass.call(input: :data) }

    let(:klass) do
      Class.new(described_class) do
        # routing to the first step in wrap
        step :first, routes(match_ok => :inside_a, match_err => :end)

        # routing for wrap result
        wrap :my_wrap, routes(match_ok => :after_b, match_err => :end) do
          # routing inside wrap
          step :inside_a, routes(match_ok => :track_inside, match_err => :end)
          step :inside_b
          track :track_inside do
            # routing inside wrap to :end must stop only wrap execution
            step :inside_c, routes(match_ok => :end, match_err => :end)
          end
        end
        step :after_a
        step :after_b

        def my_wrap(ctx, meta)
          ctx[:my_wrap] = :executed
          meta[:my_wrap] = :executed

          result = yield

          ok(**result.unwrap.merge(result: :patched))
        end

        def first(**)
          ok(first_step: :executed)
        end

        def inside_a(**)
          ok(inside_a_step: :executed)
        end

        def inside_b(**)
          ok(inside_b_step: :executed)
        end

        def inside_c(**)
          ok(inside_c_step: :executed)
        end

        def after_a(**)
          ok(after_a_step: :executed)
        end

        def after_b(**)
          ok(after_b_step: :executed)
        end
      end
    end

    let(:expected_context) do
      {
        input: :data,
        first_step: :executed,
        inside_a_step: :executed,
        inside_c_step: :executed,
        my_wrap: :executed,
        after_b_step: :executed,
        result: :patched
      }
    end

    let(:expected_meta) do
      {
        my_wrap: :executed
      }
    end

    it 'returns expected context' do
      expect(calculation.unwrap).to eq expected_context
    end

    it 'returns expected meta' do
      expect(calculation.meta).to eq expected_meta
    end
  end

  describe 'wrap DSL (invalid routing inside wrap)' do
    include Flows::Result::Helpers
    include_context 'with helpers'

    subject(:calculation) { klass.call(input: :data) }

    let(:klass) do
      Class.new(described_class) do
        step :first, routes(match_ok => :inside_b, match_err => :end)
        wrap :my_wrap do
          step :inside_a
          step :inside_b
        end

        def my_wrap(ctx, meta)
          ctx[:my_wrap] = :executed
          meta[:my_wrap] = :executed

          result = yield

          ok(**result.unwrap.merge(result: :patched))
        end

        def first(**)
          ok(first_step: :executed)
        end

        def inside_a(**)
          ok(inside_a_step: :executed)
        end

        def inside_b(**)
          ok(inside_b_step: :executed)
        end
      end
    end

    it 'raises routing error' do
      expect { calculation }.to raise_error Flows::Flow::InvalidNodeRouteError
    end
  end

  describe 'wrap DSL (invalid routing outside wrap)' do
    include Flows::Result::Helpers
    include_context 'with helpers'

    subject(:calculation) { klass.call(input: :data) }

    let(:klass) do
      Class.new(described_class) do
        step :first
        wrap :my_wrap do
          step :inside, routes(match_ok => :after, match_err => :end)
        end
        step :after

        def my_wrap(ctx, meta)
          ctx[:my_wrap] = :executed
          meta[:my_wrap] = :executed

          result = yield

          ok(**result.unwrap.merge(result: :patched))
        end

        def first(**)
          ok(first_step: :executed)
        end

        def inside(**)
          ok(inside_step: :executed)
        end

        def after(**)
          ok(after_step: :executed)
        end
      end
    end

    it 'raises routing error' do
      expect { calculation }.to raise_error Flows::Flow::InvalidNodeRouteError
    end
  end

  describe 'wrap DSL and inheritace' do
    include Flows::Result::Helpers
    include_context 'with helpers'

    subject(:calculation) { klass.call(input: :data) }

    let(:klass) { Class.new(parent_klass) }

    let(:parent_klass) do
      Class.new(described_class) do
        step :first
        wrap :my_wrap do
          step :inside_a
        end
        wrap :my_wrap do
          step :inside_b
        end

        def my_wrap(ctx, meta)
          ctx[:my_wrap] ||= []
          ctx[:my_wrap] << :executed

          meta[:my_wrap] ||= []
          meta[:my_wrap] << :executed

          result = yield

          ok(**result.unwrap.merge(result: :patched))
        end

        def first(**)
          ok(first_step: :executed)
        end

        def inside_a(**)
          ok(inside_a_step: :executed)
        end

        def inside_b(**)
          ok(inside_b_step: :executed)
        end
      end
    end

    let(:expected_context) do
      {
        input: :data,
        first_step: :executed,
        inside_a_step: :executed,
        inside_b_step: :executed,
        my_wrap: %i[executed executed],
        result: :patched
      }
    end

    let(:expected_meta) do
      {
        my_wrap: %i[executed executed]
      }
    end

    it 'returns expected context' do
      expect(calculation.unwrap).to eq expected_context
    end

    it 'returns expected meta' do
      expect(calculation.meta).to eq expected_meta
    end
  end
end
