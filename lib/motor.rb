require "motor/version"
require "motor/admin"
require "motor/api"
require "motor/assets"

module Motor
  module_function

  def development?
    ENV['MOTOR_DEVELOPMENT'].present?
  end
end
