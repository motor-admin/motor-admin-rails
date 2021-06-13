# frozen_string_literal: true

module Motor
  class Admin < ::Rails::Engine
    initializer 'motor.startup_message' do
      config.after_initialize do
        next unless Motor.server?

        Rails.application.reload_routes!

        if Rails.application.routes.url_helpers.respond_to?(:motor_admin_path)
          url =
            begin
              Rails.application.routes.url_helpers.motor_admin_url
            rescue ArgumentError
              Rails.application.routes.url_helpers.motor_admin_path
            end

          puts
          puts "⚡ Motor::Admin is starting under #{url}"
        else
          puts
          puts '⚠️  Motor::Admin is not mounted.'
          puts 'Add the following line to your config/routes.rb:'
          puts
          puts "    mount Motor::Admin => '/admin'"
        end

        puts
      end
    end

    initializer 'motor.configs.sync_middleware' do
      next if Motor::Configs::SYNC_ACCESS_KEY.blank?

      require 'motor/configs/sync_middleware'

      Rails.application.config.middleware.insert_after(Rails::Rack::Logger, Motor::Configs::SyncMiddleware)
    end

    initializer 'motor.filter_params' do
      Rails.application.config.filter_parameters += %i[io]
    end

    initializer 'motor.alerts.scheduler' do
      config.after_initialize do
        next unless Motor.server?

        Motor::Alerts::Scheduler::SCHEDULER_TASK.execute
      end
    end

    initializer 'motor.basic_auth' do
      next if ENV['MOTOR_AUTH_PASSWORD'].blank?

      config.middleware.use Rack::Auth::Basic do |username, password|
        ActiveSupport::SecurityUtils.secure_compare(
          ::Digest::SHA256.hexdigest(username),
          ::Digest::SHA256.hexdigest(ENV['MOTOR_AUTH_USERNAME'].to_s)
        ) &
          ActiveSupport::SecurityUtils.secure_compare(
            ::Digest::SHA256.hexdigest(password),
            ::Digest::SHA256.hexdigest(ENV['MOTOR_AUTH_PASSWORD'].to_s)
          )
      end
    end

    initializer 'motor.active_storage.extensions' do
      config.after_initialize do
        next unless defined?(ActiveStorage::Engine)

        ActiveSupport.on_load(:active_storage_attachment) do
          ActiveStorage::Attachment.include(Motor::ActiveRecordUtils::ActiveStorageLinksExtension)
        end

        ActiveSupport.on_load(:active_storage_blob) do
          ActiveStorage::Blob.singleton_class.prepend(Motor::ActiveRecordUtils::ActiveStorageBlobPatch)
        end

        ActiveStorage::Attachment.include(Motor::ActiveRecordUtils::ActiveStorageLinksExtension)
        ActiveStorage::Blob.singleton_class.prepend(Motor::ActiveRecordUtils::ActiveStorageBlobPatch)
      end
    end
  end
end
