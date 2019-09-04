require 'spec_helper'

RSpec.describe Flows::Operation do
  include ::Flows::Result::Helpers

  describe 'step definition by symbol' do
    context 'when instance method with same name exists' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data

          def build_result(**)
            ok(data: 'some data')
          end
        end
      end

      it 'uses this method as step body' do
        expect(invoke.unwrap).to eq(data: 'some data')
      end
    end

    context 'when no instance method with such name' do
      subject(:build) { operation_class.new }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data
        end
      end

      it 'raises error when building' do
        expect { build }.to raise_error Flows::Operation::NoStepImplementationError, /build_result/
      end
    end
  end

  describe 'step definition by symbol & lambda' do
    context 'when no instance method with same name exists' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :do_job, ->(**) { ok(data: 'from lambda') }

          success :data
        end
      end

      it 'executes lambda' do
        expect(invoke.unwrap[:data]).to eq 'from lambda'
      end
    end

    context 'when instance method with same name exists' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :do_job, ->(**) { ok(data: 'from lambda') }

          success :data

          def do_job(**)
            ok(data: 'from method')
          end
        end
      end

      it 'executes lambda' do
        expect(invoke.unwrap[:data]).to eq 'from lambda'
      end
    end

    context 'with routing' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :do_job,
               ->(**) { ok(data: 'from lambda') },
               match_ok => :term

          step :panic, ->(**) { raise 'should not be here' }

          success :data
        end
      end

      it 'uses routing' do
        expect { invoke }.not_to raise_error
      end
    end
  end

  describe 'success shape with implicit default status' do
    context 'when defined, result has :success status and data conforms shape' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data

          def build_result(**)
            ok(data: 'data', not_a_data: 'not a data')
          end
        end
      end

      it { is_expected.to be_ok }

      it 'returns filtered data' do
        expect(invoke.unwrap).to eq(data: 'data')
      end
    end

    context 'when defined, result has :success status and data does not conform shape' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data

          def build_result(**)
            ok(out_of_shape: 'data', not_a_data: 'not a data')
          end
        end
      end

      it 'raises exception on execution' do
        expect { invoke }.to raise_error Flows::Operation::MissingOutputError, /data/
      end
    end

    context 'when defined, result has non-standard status' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data

          def build_result(**)
            ok(:custom_status, data: 'data', not_a_data: 'not a data')
          end
        end
      end

      it 'raises exception on execution' do
        expect { invoke }.to raise_error Flows::Operation::UnexpectedSuccessStatusError, /custom_status/
      end
    end

    context 'when undefined' do
      subject(:build) { operation_class.new }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          def build_result(**)
            ok(data: 'data', not_a_data: 'not a data')
          end
        end
      end

      it 'raises exception when building' do
        expect { build }.to raise_error Flows::Operation::NoSuccessShapeError
      end
    end
  end

  describe 'success shapes with explicit statuses' do
    context 'when result conforms status and shape' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success type_a: %i[data],
                  type_b: %i[value]

          def build_result(**)
            ok(:type_b, value: 'some value')
          end
        end
      end

      it { is_expected.to be_ok }

      it 'returns expected status' do
        expect(invoke.status).to eq :type_b
      end

      it 'returns expected data' do
        expect(invoke.unwrap).to eq(value: 'some value')
      end
    end

    context 'when result status mistmatches' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success type_a: %i[data],
                  type_b: %i[value]

          def build_result(**)
            ok(value: 'some value')
          end
        end
      end

      it 'raises exception on execution' do
        expect { invoke }.to raise_error Flows::Operation::UnexpectedSuccessStatusError
      end
    end
  end

  describe 'failure shape with implicit default status' do
    context 'when defined, result has :failure status and data conforms shape' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data
          failure :error

          def build_result(**)
            err(error: 'some error', data: 'data')
          end
        end
      end

      it { is_expected.to be_err }

      it 'returns filtered data' do
        expect(invoke.error).to eq(error: 'some error')
      end
    end

    context 'when defined, result has :failure status and data does not conform shape' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data
          failure :error

          def build_result(**)
            err(data: 'some data')
          end
        end
      end

      it 'raises exception on execution' do
        expect { invoke }.to raise_error Flows::Operation::MissingOutputError, /error/
      end
    end

    context 'when defined, result has non-standard status' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data
          failure :error

          def build_result(**)
            err(:custom_status, error: 'some error')
          end
        end
      end

      it 'raises exception on execution' do
        expect { invoke }.to raise_error Flows::Operation::UnexpectedFailureStatusError, /custom_status/
      end
    end

    context 'when undefined' do
      subject(:build) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data

          def build_result(**)
            err(error: 'some error')
          end
        end
      end

      it 'raises exception on execution' do
        expect { build }.to raise_error Flows::Operation::NoFailureShapeError
      end
    end
  end

  describe 'failure shapes with explicit statuses' do
    context 'when result conforms status and shape' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data
          failure validation: %i[errors],
                  exception: %i[exceptions]

          def build_result(**)
            err(:validation, errors: 'some errors')
          end
        end
      end

      it { is_expected.to be_err }

      it 'returns expected status' do
        expect(invoke.status).to eq :validation
      end

      it 'returns expected data' do
        expect(invoke.error).to eq(errors: 'some errors')
      end
    end

    context 'when result status mistmatches' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :build_result

          success :data
          failure validation: %i[errors],
                  exception: %i[exceptions]

          def build_result(**)
            err(:unexpected, errors: 'some errors')
          end
        end
      end

      it 'raises exception on execution' do
        expect { invoke }.to raise_error Flows::Operation::UnexpectedFailureStatusError
      end
    end
  end

  describe 'with disabled shape checks' do
    subject(:invoke) { operation_class.new.call }

    let(:operation_class) do
      Class.new do
        include Flows::Operation

        step :do_job

        no_shape_checks

        def do_job(**)
          ok(data: :any_shape)
        end
      end
    end

    it 'successfuly executes' do
      expect(invoke.unwrap[:data]).to eq(:any_shape)
    end
  end

  describe 'override standard routing' do
    context 'when overrides default routing' do
      subject(:operation) { operation_class.new }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :resolve,
               match_ok => :term,
               match_err => :last_step

          step :last_step

          success :data

          def resolve(path:, **)
            case path
            when :ok then ok(data: 'ok path')
            when :err then err(data: 'err path')
            end
          end

          def last_step(**)
            ok(data: 'from last step')
          end
        end
      end

      it 'overrides ok result routing' do
        expect(operation.call(path: :ok).unwrap[:data]).to eq 'ok path'
      end

      it 'overrides err result routing' do
        expect(operation.call(path: :err).unwrap[:data]).to eq 'from last step'
      end
    end

    context 'when overrides status-specific routing' do
      subject(:operation) { operation_class.new }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :resolve, match_ok(:end_now) => :term
          step :last_step

          success success: [:data],
                  end_now: [:data]

          def resolve(path:, **)
            case path
            when :ok then ok(data: 'ok path')
            when :ok_end_now then ok(:end_now, data: 'ok short path')
            end
          end

          def last_step(**)
            ok(data: 'from last step')
          end
        end
      end

      it 'preserves standard roting for ok' do
        expect(operation.call(path: :ok).unwrap[:data]).to eq 'from last step'
      end

      it 'adds status specific routing' do
        expect(operation.call(path: :ok_end_now).unwrap[:data]).to eq 'ok short path'
      end
    end
  end

  describe 'using side track' do
    context 'when simple track present' do
      subject(:operation) { operation_class.new }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :first, match_ok(:track) => :side_track

          track :side_track do
            step :on_track
          end

          step :last

          success success: [:data],
                  on_track: [:data]

          def first(route:, **)
            case route
            when :direct then ok
            when :track then ok(:track)
            end
          end

          def on_track(**)
            ok(data: 'from track')
          end

          def last(data: false, **)
            return ok(:on_track) if data

            ok(data: 'from direct path')
          end
        end
      end

      it 'works in direct path case' do
        expect(operation.call(route: :direct).status).to eq :success
      end

      it 'works in track path case' do
        expect(operation.call(route: :track).status).to eq :on_track
      end
    end

    context 'when nested track present' do
      subject(:operation) { operation_class.new }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :first, match_ok(:track) => :side_track

          track :side_track do
            step :side_track_begin, match_ok(:inner) => :inner_track
            track :inner_track do
              step :on_inner_track
            end
            step :side_track_end
          end

          step :last

          success success: [:path]

          def first(route:, **)
            path = [:first]

            case route
            when :direct then ok(path: path)
            when :track, :inner then ok(:track, path: path)
            end
          end

          def side_track_begin(route:, path:, **)
            path += [:side_track_begin]

            if route == :inner
              ok(:inner, path: path)
            else
              ok(path: path)
            end
          end

          def on_inner_track(path:, **)
            ok(path: path + [:on_inner_track])
          end

          def side_track_end(path:, **)
            ok(path: path + [:side_track_end])
          end

          def last(path:, **)
            ok(path: path + [:last])
          end
        end
      end

      it 'works in direct path case' do
        expect(operation.call(route: :direct).unwrap[:path]).to eq %i[first last]
      end

      it 'works in track path case' do
        expect(operation.call(route: :track).unwrap[:path]).to eq %i[first side_track_begin side_track_end last]
      end

      it 'works in inner track path case' do
        expect(operation.call(route: :inner).unwrap[:path]).to(
          eq %i[first side_track_begin on_inner_track side_track_end last]
        )
      end
    end
  end

  describe 'wrapping steps' do
    context 'when wrap used on root level' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :init

          wrap :wrapper do
            step :first
          end

          step :last

          success :path, :path_before_wrap

          def init(**)
            ok(path: [:init])
          end

          def wrapper(path:, **)
            result = yield
            ok(path_before_wrap: path, path: result.unwrap[:path] + [:wrapper])
          end

          def first(path:, **)
            ok(path: path + [:first])
          end

          def last(path:, **)
            ok(path: path + [:last])
          end
        end
      end

      it 'executes steps in a correct order' do
        expect(invoke.unwrap[:path]).to eq %i[init first wrapper last]
      end

      it 'starts wrapping in a correct place' do
        expect(invoke.unwrap[:path_before_wrap]).to eq %i[init]
      end
    end

    context 'when wrap used inside track' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :init, match_ok => :wrapped_track

          track :wrapped_track do
            wrap :wrapper do
              step :first
            end
          end

          step :last

          success :path, :path_before_wrap

          def init(**)
            ok(path: [:init])
          end

          def wrapper(path:, **)
            result = yield
            ok(path_before_wrap: path, path: result.unwrap[:path] + [:wrapper])
          end

          def first(path:, **)
            ok(path: path + [:first])
          end

          def last(path:, **)
            ok(path: path + [:last])
          end
        end
      end

      it 'executes steps in a correct order' do
        expect(invoke.unwrap[:path]).to eq %i[init first wrapper last]
      end

      it 'starts wrapping in a correct place' do
        expect(invoke.unwrap[:path_before_wrap]).to eq %i[init]
      end
    end

    context 'when wrap used with lambda' do
      subject(:invoke) { operation_class.new.call }

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :init

          wrap(
            :wrapper,
            lambda do |path:, **, &block|
              result = block.call
              ok(path_before_wrap: path, path: result.unwrap[:path] + [:wrapper])
            end
          ) do
            step :first
          end

          step :last

          success :path, :path_before_wrap

          def init(**)
            ok(path: [:init])
          end

          def first(path:, **)
            ok(path: path + [:first])
          end

          def last(path:, **)
            ok(path: path + [:last])
          end
        end
      end

      it 'executes steps in a correct order' do
        expect(invoke.unwrap[:path]).to eq %i[init first wrapper last]
      end

      it 'starts wrapping in a correct place' do
        expect(invoke.unwrap[:path_before_wrap]).to eq %i[init]
      end
    end
  end

  describe 'override step implementation with deps' do
    context 'when there is no step implementation' do
      subject(:invoke) do
        operation_class.new(deps: {
                              do_job: ->(**) { ok(data: 'from deps') }
                            }).call
      end

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :do_job

          success :data
        end
      end

      it 'uses step implementation from deps' do
        expect(invoke.unwrap[:data]).to eq 'from deps'
      end
    end

    context 'when step implementation presents in operation' do
      subject(:invoke) do
        operation_class.new(deps: {
                              do_job: ->(**) { ok(data: 'from deps') }
                            }).call
      end

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :do_job

          success :data

          def do_job(**)
            ok(data: 'from class')
          end
        end
      end

      it 'uses step implementation from deps' do
        expect(invoke.unwrap[:data]).to eq 'from deps'
      end
    end

    context 'when step inside wrap' do
      subject(:invoke) do
        operation_class.new(deps: {
                              do_job: ->(**) { ok(data: 'from deps') }
                            }).call
      end

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          wrap :wrapper do
            step :do_job
          end

          success :data

          def wrapper(**)
            yield
          end
        end
      end

      it 'uses step implementation from deps' do
        expect(invoke.unwrap[:data]).to eq 'from deps'
      end
    end

    context 'when step in side track' do
      subject(:invoke) do
        operation_class.new(deps: {
                              do_job: ->(**) { ok(data: 'from deps') }
                            }).call
      end

      let(:operation_class) do
        Class.new do
          include Flows::Operation

          step :to_track, ->(**) { ok }, match_ok => :side_track

          track :side_track do
            step :do_job
          end

          success :data
        end
      end

      it 'uses step implementation from deps' do
        expect(invoke.unwrap[:data]).to eq 'from deps'
      end
    end
  end
end
