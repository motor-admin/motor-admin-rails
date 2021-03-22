# frozen_string_literal: true

require 'cancancan'
require 'ar_lazy_preload'
require 'js_regex'

require 'motor/version'
require 'motor/admin'
require 'motor/api'
require 'motor/assets'
require 'motor/build_schema'
require 'motor/api_query'
require 'motor/tags'
require 'motor/queries'
require 'motor/dashboards'
require 'motor/hash_serializer'
require 'motor/active_record_utils'

module Motor
  PATH = Pathname.new(__dir__)

  module_function

  def reload!
    Kernel.silence_warnings do
      Dir[PATH.join('./motor/**/*.rb')].each { |f| load f }
    end

    true
  end

  def development?
    ENV['MOTOR_DEVELOPMENT'].present?
  end
end
