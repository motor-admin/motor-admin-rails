# frozen_string_literal: true

module Motor
  class SessionsController < ApiBaseController
    skip_authorization_check

    def destroy
      session.clear

      head :ok
    end
  end
end
