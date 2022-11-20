# frozen_string_literal: true

module Motor
  module CurrentUserMethod
    def current_user
      @current_user ||=
        if defined?(current_admin)
          current_admin
        elsif defined?(current_admin_user)
          return Motor::AdminUser.public if current_admin_user.nil? && Motor.with_public_access?

          current_admin_user
        elsif defined?(super)
          super
        end
    end
  end
end
