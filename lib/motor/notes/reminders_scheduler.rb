# frozen_string_literal: true

module Motor
  module Notes
    module RemindersScheduler
      SCHEDULER_INTERVAL = 1.minute
      CHECK_BEHIND_DURATION = 6.hours

      SCHEDULER_TASK = Concurrent::TimerTask.new(
        execution_interval: SCHEDULER_INTERVAL
      ) { Motor::Notes::RemindersScheduler.call }

      REMINDER_NOTIFICATIONS_JOIN_SQL = <<~SQL.squish
        LEFT JOIN motor_notifications
        ON cast(motor_notifications.record_id as int) = motor_reminders.id
        AND motor_notifications.record_type = 'Motor::Reminder'
      SQL

      module_function

      def call
        ActiveRecord::Base.logger.silence do
          load_reminders.each do |reminder|
            ::Motor::NotifyReminderJob.perform_later(reminder)
          rescue StandardError => e
            Rails.logger.error(e)
          end
        end
      end

      def load_reminders
        ::Motor::Reminder
          .joins(REMINDER_NOTIFICATIONS_JOIN_SQL)
          .where(scheduled_at: CHECK_BEHIND_DURATION.ago..Time.current.end_of_minute)
          .where(motor_notifications: { id: nil })
      end
    end
  end
end
