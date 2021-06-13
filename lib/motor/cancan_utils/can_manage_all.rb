# frozen_string_literal: true

module Motor
  module CancanUtils
    class CanManageAll
      include CanCan::Ability
      prepend CancanUtils::AbilityPatch

      def initialize(_ = nil)
        can :manage, :all
      end
    end
  end
end
