# frozen_string_literal: true

module Motor
  class ApiBaseController < ActionController::API
    def current_user
      if defined?(current_admin)
        current_admin
      elsif defined?(current_admin_user)
        current_admin_user
      elsif defined?(super)
        super
      end
    end

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
