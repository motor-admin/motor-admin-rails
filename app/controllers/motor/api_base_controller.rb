# frozen_string_literal: true

module Motor
  class ApiBaseController < ActionController::API
    include Motor::CurrentUserMethod
    include Motor::CurrentAbility

    if defined?(ActionText::Content)
      before_action do
        ActionText::Content.renderer = Motor::ApplicationController.renderer.new(request.env)
      end
    end

    unless Rails.env.test?
      rescue_from StandardError do |e|
        Rails.logger.error(e)
        Rails.logger.error(e.backtrace.join("\n"))

        render json: { errors: [e.message] }, status: :internal_server_error
      end
    end
  end
end
