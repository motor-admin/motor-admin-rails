# frozen_string_literal: true

require 'concurrent/executor/fixed_thread_pool'
require 'concurrent/timer_task'
require 'cancancan'
require 'ar_lazy_preload'
require 'fugit'
require 'csv'
require 'audited'
require 'uri'
require 'net/http'
require 'net/https'

module Motor
  PATH = Pathname.new(__dir__)

  module DatabaseClasses
  end

  module_function

  def reload!
    Kernel.silence_warnings do
      Dir[PATH.join('./motor/**/*.rb')].each do |f|
        next if f.ends_with?('alerts/scheduler.rb')
        next if f.ends_with?('notes/reminders_scheduler.rb')
        next if f.ends_with?('alerts/scheduled_alerts_cache.rb')
        next if f.ends_with?('configs/load_from_cache.rb')
        next if f.ends_with?('configs/sync_from_file.rb')
        next if f.ends_with?('resources/custom_sql_columns_cache.rb')

        load f
      end
    end

    true
  end

  def server?
    defined?(::Rails::Server) ||
      defined?(::Thin::Server) ||
      defined?(::PhusionPassenger) ||
      (defined?(::Puma) && File.basename($PROGRAM_NAME) == 'puma') ||
      defined?(::Unicorn::HttpServer) ||
      defined?(::Mongrel::HttpServer) ||
      defined?(JRuby::Rack::VERSION) ||
      defined?(::Trinidad::Server)
  end

  def app_host
    Rails.application.config.action_dispatch.default_url_options&.fetch(:host) ||
      ENV.fetch('HOST', 'example.com')
  end

  def company_name
    'Motor Admin'
  end

  def with_public_access?
    ENV['MOTOR_PUBLIC_ACCESS'].to_s == 'true'
  end

  def development?
    ENV['MOTOR_DEVELOPMENT'].present?
  end
end

require 'motor/version'
require 'motor/admin'
require 'motor/assets'
require 'motor/active_record_utils'
require 'motor/cancan_utils'
require 'motor/build_schema'
require 'motor/api_query'
require 'motor/tags'
require 'motor/configs'
require 'motor/queries'
require 'motor/dashboards'
require 'motor/forms'
require 'motor/api_configs'
require 'motor/alerts'
require 'motor/slack'
require 'motor/resources'
require 'motor/notes'
require 'motor/hash_serializer'
require 'motor/net_http_utils'
require 'motor/railtie'
