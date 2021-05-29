# frozen_string_literal: true

module Motor
  class ApiBaseController < ActionController::API
    include Motor::CurrentUserMethod

    class CanCanAbilityManageAll
      include CanCan::Ability

      def initialize(_)
        can :manage, :all
      end
    end

    unless Rails.env.test?
      rescue_from StandardError do |e|
        Rails.logger.error(e)

        render json: { errors: [e.message] }, status: :internal_server_error
      end
    end

    def current_ability
      CanCanAbilityManageAll.new(current_user)
    end
  end
end
