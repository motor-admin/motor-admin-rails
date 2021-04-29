# frozen_string_literal: true

module Motor
  class Admin < ::Rails::Engine
    initializer 'motor.filter_params' do
      Rails.application.config.filter_parameters += %i[io]
    end

    initializer 'motor.alerts.scheduler' do
      config.after_initialize do |_app|
        next if defined?(Sidekiq) && Sidekiq.server?

        Motor::Alerts::Scheduler::SCHEDULER_TASK.execute
        Motor::Alerts::ScheduledAlertsCache::UPDATE_ALERTS_TASK.execute
      end
    end

    initializer 'motor.active_storage.extensions' do
      ActiveSupport.on_load(:active_storage_attachment) do
        ActiveStorage::Attachment.include(Motor::ActiveRecordUtils::ActiveStorageLinksExtension)
      end
    end
  end
end
