# frozen_string_literal: true

require 'cancancan'
require 'ar_lazy_preload'
require 'js_regex'

require 'motor/version'
require 'motor/admin'
require 'motor/api'
require 'motor/assets'
require 'motor/schema'
require 'motor/query'

module Motor
  module_function

  def reload!
    Kernel.silence_warnings do
      Dir['./motor/lib/**/*.rb'].each { |f| load f }
    end
  end

  def development?
    ENV['MOTOR_DEVELOPMENT'].present?
  end
end
