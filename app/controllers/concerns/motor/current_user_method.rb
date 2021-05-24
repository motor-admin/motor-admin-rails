# frozen_string_literal: true

module Motor
  module CurrentUserMethod
    def current_user
      if defined?(current_admin)
        current_admin
      elsif defined?(current_admin_user)
        current_admin_user
      elsif defined?(super)
        super
      end
    end
  end
end
