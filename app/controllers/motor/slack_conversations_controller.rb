# frozen_string_literal: true

module Motor
  class SlackConversationsController < ApiBaseController
    def index
      authorize!(:create, Motor::Alert)

      render json: { data: Motor::Slack.conversations }
    end
  end
end
