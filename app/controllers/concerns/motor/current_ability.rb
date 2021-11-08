# frozen_string_literal: true

module Motor
  module CurrentAbility
    def current_ability
      @current_ability ||=
        if defined?(Motor::Ability)
          klass = Motor::Ability.dup.tap do |k|
            k.prepend(Motor::CancanUtils::AbilityPatch)
          end

          params = [current_user]
          params << request if Motor::Ability.instance_method(:initialize).arity == 2

          klass.new(*params)
        else
          Motor::CancanUtils::CanManageAll.new
        end
    end
  end
end
