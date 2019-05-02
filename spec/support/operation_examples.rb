module OperationExamples
  class OneStep
    include Flows::Operation

    step :calc_sum

    success :result
    failure :error

    def calc_sum(first:, second:)
      return err(error: :division_by_zero) if second.zero?

      ok(result: first / second)
    end
  end

  class DifferentOutputStatuses
    include Flows::Operation

    GUNS = %w[rifle pistol].freeze
    BLADES = %w[sword dagger].freeze

    step :pick_weapon_set
    step :pick_weapon
    step :build_result

    success team_red: [:gun],
            team_blue: [:blade]

    failure unexisting_team: %i[color],
            weapon_not_found: %i[set index]

    def pick_weapon_set(color:, **)
      weapon_set = case color
                   when 'red' then GUNS
                   when 'blue' then BLADES
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
