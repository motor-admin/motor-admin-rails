# frozen_string_literal: true

module Motor
  class UsersForAutocompleteController < ApiBaseController
    def index
      authorize!(:create, Motor::Note)

      render json: { data: user_emails }
    end

    private

    def user_emails
      user_class   = Motor::AdminUser if defined?(Motor::AdminUser)
      user_class ||= AdminUser if defined?(AdminUser)
      user_class ||= User if defined?(User)

      return user_class.distinct.limit(100).pluck(:email) if user_class

      []
    end
  end
end
