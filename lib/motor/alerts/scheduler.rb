# frozen_string_literal: true

module Motor
  module Alerts
    module Scheduler
      SCHEDULER_INTERVAL = 10.seconds
      LOOK_BEHIND_DURATION = 10.minutes

      SCHEDULER_TASK = Concurrent::TimerTask.new(
        execution_interval: SCHEDULER_INTERVAL
      ) { Motor::Alerts::Scheduler.call }

      ALREADY_PROCESSED_CACHE = ActiveSupport::Cache::MemoryStore.new(size: 10.megabytes)

      module_function

      def call
        ScheduledAlertsCache.all.each do |alert|
          next unless (LOOK_BEHIND_DURATION.ago..Time.current).cover?(alert.cron.previous_time.to_local_time)

          ALREADY_PROCESSED_CACHE.fetch("#{alert.id}-#{alert.cron.previous_time.to_i}") do
            Motor::AlertSendingJob.perform_later(alert).job_id
          end
        rescue StandardError => e
          Rials.logger.error(e)
        end
      end
    end
  end
end
