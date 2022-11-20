# frozen_string_literal: true

module Motor
  class NotificationsChannel < ::Motor::ApplicationCable::Channel
    def subscribed
      stream_for current_user if respond_to?(:current_user)
    end
  end
end
