# frozen_string_literal: true

module Motor
  class Admin < ::Rails::Engine
    initializer 'motor.alerts.scheduler' do
      next if defined?(Sidekiq) && Sidekiq.server?

      Motor::Alerts::Scheduler::SCHEDULER_TASK.execute
      Motor::Alerts::ScheduledAlertsCache::UPDATE_ALERTS_TASK.execute
    end
  end
end
