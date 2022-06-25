# frozen_string_literal: true

module Motor
  module Configs
    FILE_PATH = 'config/motor.yml'
    SYNC_API_PATH = '/motor_configs_sync'
    SYNC_ACCESS_KEY = ENV.fetch('MOTOR_SYNC_API_KEY', '')
    MEMFS_PATH = '/__enclose_io_memfs__/'
    PWD_FILE_NAME = 'motor-admin.yml'

    module_function

    def clear
      Motor::Resource.destroy_all
      Motor::Alert.destroy_all
      Motor::Query.destroy_all
      Motor::Dashboard.destroy_all
      Motor::Form.destroy_all
      Motor::ApiConfig.destroy_all
      Motor::Config.destroy_all
    end

    # @return [String]
    def file_path
      if Rails.root.to_s.start_with?(MEMFS_PATH)
        [ENV['PWD'], PWD_FILE_NAME].join('/')
      else
        Rails.root.join(FILE_PATH).to_s
      end
    end
  end
end

require_relative './configs/load_from_cache'
require_relative './configs/build_ui_app_tag'
require_relative './configs/build_configs_hash'
require_relative './configs/write_to_file'
require_relative './configs/sync_from_hash'
require_relative './configs/sync_from_file'
require_relative './configs/sync_with_remote'
