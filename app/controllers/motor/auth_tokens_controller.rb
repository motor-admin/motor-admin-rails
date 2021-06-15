# frozen_string_literal: true

module Motor
  class AuthTokensController < ApiBaseController
    GENERIC_TOKEN_TTL = 2.hours

    skip_authorization_check

    def create
      return render json: {} unless current_user

      if defined?(Devise::JWT)
        respond_with_devise_jwt
      elsif defined?(JWT)
        respond_with_generic_jwt
      else
        render json: {}
      end
    end

    private

    def respond_with_devise_jwt
      warden.set_user(current_user)

      render json: { token: request.env['warden-jwt_auth.token'] }
    end

    def respond_with_generic_jwt
      payload = { uid: current_user.id, exp: GENERIC_TOKEN_TTL.from_now.to_i }
      token = JWT.encode(payload, Rails.application.secrets.secret_key_base)

      render json: { token: token }
    end
  end
end
