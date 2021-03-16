# frozen_string_literal: true

module Motor
  class ApiBaseController < ActionController::API
    private

    def current_ability
      klass = Class.new
      klass.include(CanCan::Ability)
      klass.define_method(:initialize) do |_user|
        can :manage, :all
      end

      klass.new(current_user)
    end
  end
end
