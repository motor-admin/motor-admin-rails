# frozen_string_literal: true

module Motor
  class SessionsController < ApiBaseController
    skip_authorization_check

    def show
      render json: {
        current_user_email: current_user&.email,
        current_user_id: current_user&.id
      }
    end

    def destroy
      session.clear

      head :ok
    end
  end
end
