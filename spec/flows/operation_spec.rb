require 'spec_helper'

RSpec.describe Flows::Operation do
  let(:invoke) { operation.new.call(params) }

  describe 'simplest operation' do
    let(:operation) do
      Class.new do
        include Flows::Operation

        step :calc_sum

        success :result
        failure :error

        def calc_sum(first:, second:)
          return err(error: :division_by_zero) if second.zero?

          ok(result: first / second)
        end
      end
    end

    context 'when success path' do
      let(:params) do
        {
          first: 10,
          second: 2
        }
      end

      it { expect(invoke).to be_success }

      it 'sets :result key in result' do
        expect(invoke.unwrap).to eq(result: 5)
      end
    end

    context 'when failure path' do
      let(:params) do
        {
          first: 10,
          second: 0
        }
      end

      it { expect(invoke).to be_failure }

      it 'sets :result key in result' do
        expect(invoke.error).to eq(error: :division_by_zero)
      end
    end
  end

  describe 'two success result variants and two errors variants' do
    let(:operation) do
      Class.new do
        include Flows::Operation

        def guns
          %w[rifle pistol]
        end

        def blades
          %w[sword dagger]
        end

        step :pick_weapon_set
        step :pick_weapon
        step :build_result

        success team_red: [:gun],
                team_blue: [:blade]

        failure unexisting_team: %i[color],
                weapon_not_found: %i[set index]

        def pick_weapon_set(color:, **)
          weapon_set = case color
                       when 'red' then guns
                       when 'blue' then blades
                       else return err(:unexisting_team, color: color)
                       end

          ok(weapon_set: weapon_set)
        end

        def pick_weapon(weapon_index:, weapon_set:, **)
          weapon = weapon_set[weapon_index]

          return err(:weapon_not_found, set: weapon_set, index: weapon_index) if weapon.nil?

          ok(weapon: weapon)
        end

        def build_result(weapon:, color:, **)
          case color
          when 'red' then ok(:team_red, gun: weapon)
          when 'blue' then ok(:team_blue, blade: weapon)
          end
        end
      end
    end

    context 'when success :team_red path' do
      let(:params) do
        {
          color: 'red',
          weapon_index: 0
        }
      end

      it { expect(invoke).to be_success }

      it 'has status :team_red' do
        expect(invoke.status).to eq :team_red
      end

      it do
        expect(invoke.unwrap).to eq(gun: 'rifle')
      end
    end

    context 'when success :team_blue path' do
      let(:params) do
        {
          color: 'blue',
          weapon_index: 1
        }
      end

      it { expect(invoke).to be_success }

      it 'has status :team_red' do
        expect(invoke.status).to eq :team_blue
      end

      it do
        expect(invoke.unwrap).to eq(blade: 'dagger')
      end
    end

    context 'when failure :unexisting_team path' do
      let(:params) do
        {
          color: 'black',
          weapon_index: 1
        }
      end

      it { expect(invoke).to be_failure }

      it 'has status :unexisting_team' do
        expect(invoke.status).to eq :unexisting_team
      end

      it do
        expect(invoke.error).to eq(color: 'black')
      end
    end

    context 'when failure :weapon_not_found path' do
      let(:params) do
        {
          color: 'red',
          weapon_index: 100
        }
      end

      it { expect(invoke).to be_failure }

      it 'has status :weapon_not_found' do
        expect(invoke.status).to eq :weapon_not_found
      end

      it do
        expect(invoke.error).to eq(set: operation.new.guns, index: 100)
      end
    end
  end
end
