# frozen_string_literal: true

require 'cancancan'
require 'ar_lazy_preload'
require 'js_regex'
require 'fugit'
require 'csv'
require 'active_record/filter'

module Motor
  PATH = Pathname.new(__dir__)

  module_function

  def reload!
    Kernel.silence_warnings do
      Dir[PATH.join('./motor/**/*.rb')].each do |f|
        next if f.ends_with?('alerts/scheduler.rb')
        next if f.ends_with?('alerts/scheduled_alerts_cache.rb')
        next if f.ends_with?('ui_configs.rb')

        load f
      end
    end

    true
  end

  def development?
    ENV['MOTOR_DEVELOPMENT'].present?
  end
end

require 'motor/version'
require 'motor/admin'
require 'motor/api'
require 'motor/assets'
require 'motor/build_schema'
require 'motor/api_query'
require 'motor/tags'
require 'motor/ui_configs'
require 'motor/queries'
require 'motor/dashboards'
require 'motor/alerts'
require 'motor/hash_serializer'
require 'motor/active_record_utils'
