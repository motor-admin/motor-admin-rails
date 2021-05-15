# frozen_string_literal: true

module Motor
  module Configs
    FILE_PATH = 'config/motor.yml'
    SYNC_API_PATH = '/motor_configs_sync'
    SYNC_ACCESS_KEY = ENV.fetch('MOTOR_SYNC_API_KEY', '')
  end
end

require_relative './configs/load_from_cache'
require_relative './configs/build_ui_app_tag'
require_relative './configs/build_configs_hash'
require_relative './configs/write_to_file'
require_relative './configs/sync_from_hash'
require_relative './configs/sync_from_file'
require_relative './configs/sync_with_remote'
