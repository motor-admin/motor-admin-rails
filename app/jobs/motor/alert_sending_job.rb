# frozen_string_literal: true

module Motor
  class AlertSendingJob < ApplicationJob
    def perform(alert)
      Motor::AlertLock.create!(alert_id: alert.id, lock_timestamp: alert.cron.previous_time.to_i)

      Motor::Alerts.send_alert(alert)
    rescue ActiveRecord::RecordNotUnique
      nil
    end
  end
end
