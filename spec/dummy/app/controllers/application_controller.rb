# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def current_ability
    if current_user
      Motor::Ability.new(current_user)
    else
      Motor::CancanUtils::CanManageAll.new
    end
  end
end
