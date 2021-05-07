# frozen_string_literal: true

module Motor
  class Admin < ::Rails::Engine
    initializer 'motor.startup_message' do
      ActiveSupport::Notifications.subscribe('motor.routes.loaded') do
        next unless Motor.server?

        if Rails.application.routes.url_helpers.respond_to?(:motor_admin_path)
          url =
            begin
              Rails.application.routes.url_helpers.motor_admin_url
            rescue ArgumentError
              Rails.application.routes.url_helpers.motor_admin_path
            end

          puts
          puts "⚡ Motor Admin is starting under #{url}"
          puts
        end
      end
    end

    initializer 'motor.filter_params' do
      Rails.application.config.filter_parameters += %i[io]
    end

    initializer 'motor.alerts.scheduler' do
      config.after_initialize do |_app|
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
      ActiveSupport.on_load(:active_storage_attachment) do
        ActiveStorage::Attachment.include(Motor::ActiveRecordUtils::ActiveStorageLinksExtension)
      end
    end
  end
end
