# frozen_string_literal: true

module Motor
  class ApiBaseController < ActionController::API
    include Motor::CurrentUserMethod
    include Motor::CurrentAbility

    unless Rails.env.test?
      rescue_from StandardError do |e|
        Rails.logger.error(e)

        render json: { errors: [e.message] }, status: :internal_server_error
      end
    end
  end
end
