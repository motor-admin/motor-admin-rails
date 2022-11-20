# frozen_string_literal: true

module Motor
  class NotifyReminderJob < ApplicationJob
    def perform(reminder)
      Motor::Notes::NotifyReminder.call(reminder)
    end
  end
end
