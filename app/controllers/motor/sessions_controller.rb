# frozen_string_literal: true

module Motor
  class SessionsController < ApiBaseController
    include ActionController::Cookies

    skip_authorization_check

    def show
      render json: {
        current_user_email: current_user&.email,
        current_user_id: current_user&.id
      }
    end

    def destroy
      session.clear
      cookies.clear

      head :ok
    end
  end
end
