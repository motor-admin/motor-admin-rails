# frozen_string_literal: true

module Motor
  class Admin < ::Rails::Engine
    config.custom_html = ''

    ActiveSupport.cache_format_version = (Rails.version.to_f > 7.1) ? 7.1 : Rails.version.to_f

    if !Motor.development? && Rails.env.development?
      config.eager_load_paths.delete(File.expand_path('../../app/controllers', __dir__))
      config.eager_load_paths.delete(File.expand_path('../../app/controllers/concerns', __dir__))
      config.eager_load_paths.delete(File.expand_path('../../app/models', __dir__))

      config.autoload_once_paths << File.expand_path('../../app/models', __dir__)
      config.autoload_once_paths << File.expand_path('../../app/controllers', __dir__)
      config.autoload_once_paths << File.expand_path('../../app/controllers/concerns', __dir__)
    end

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
      Rails.application.config.filter_parameters += [/\Aio\z/]
    end

    initializer 'motor.alerts.scheduler' do
      config.after_initialize do
        next unless Motor.server?
        next unless Rails.env.production?

        Motor::Alerts::Scheduler::SCHEDULER_TASK.execute
        Motor::Notes::RemindersScheduler::SCHEDULER_TASK.execute
      end
    end

    initializer 'motor.basic_auth' do
      motor_username = ENV['MOTOR_AUTH_USERNAME'].presence || Rails.application.credentials.dig(:motor, :username)
      motor_password = ENV['MOTOR_AUTH_PASSWORD'].presence || Rails.application.credentials.dig(:motor, :password)
      next if motor_username.blank? || motor_password.blank?

      config.middleware.use Rack::Auth::Basic do |username, password|
        ActiveSupport::SecurityUtils.secure_compare(
          ::Digest::SHA256.hexdigest(username),
          ::Digest::SHA256.hexdigest(motor_username.to_s)
        ) &
          ActiveSupport::SecurityUtils.secure_compare(
            ::Digest::SHA256.hexdigest(password),
            ::Digest::SHA256.hexdigest(motor_password.to_s)
          )
      end
    end

    initializer 'warden.configure.dispatch_requests' do
      next unless defined?(Warden::JWTAuth)

      config.after_initialize do
        Warden::JWTAuth.configure do |config|
          config.dispatch_requests += [
            ['POST', /\A#{Regexp.escape(Motor::Admin.routes.url_helpers.motor_api_auth_tokens_path)}\z/]
          ]
        end
      end
    end

    initializer 'action_cable.connection_class' do
      config.after_initialize do
        next if defined?(::ApplicationCable::Connection)
        next unless defined?(::ActionCable)

        ActionCable.server.config.connection_class = -> { Motor::ApplicationCable::Connection }
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

    initializer 'motor.upgrade' do
      ActiveSupport.on_load(:motor_query) do
        next unless Motor.server?

        unless Motor::Query.table_exists?
          puts
          puts '  => Run `rails g motor:install && rake db:migrate` in order to create Motor Admin configuration tables'
          puts
        end

        if !Motor::ApiConfig.table_exists? || !Motor::Note.table_exists?
          puts
          puts '  => Run `rails g motor:upgrade && rake db:migrate` ' \
               'to perform data migration and enable the latest features'
          puts
        end
      end
    end
  end
end
