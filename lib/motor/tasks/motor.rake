# frozen_string_literal: true

namespace :motor do
  desc 'Update configs/motor.yml file'

  task install: :environment do
    Rails::Generators.invoke('motor:install')
  end

  task dump: :environment do
    Motor::Configs::WriteToFile.write_with_lock

    puts '✅ configs/motor.yml has been updated'
  end

  desc 'Load configs from configs/motor.yml file'

  task load: :environment do
    Motor::Configs::SyncFromFile.call(with_exception: true)

    puts '✅ configs have been loaded from configs/motor.yml'
  end

  task reload: :environment do
    ActiveRecord::Base.transaction do
      Motor::Configs.clear
      Motor::Configs::SyncFromFile.call(with_exception: true)
    end

    puts '✅ configs have been loaded from configs/motor.yml'
  end

  desc 'Synchronize configs with remote application'

  task sync: :environment do
    remote_url = ENV['MOTOR_SYNC_REMOTE_URL']
    api_key = ENV['MOTOR_SYNC_API_KEY']

    raise 'Specify target app url using `MOTOR_SYNC_REMOTE_URL` env variable' if remote_url.blank?
    raise 'Specify sync api key using `MOTOR_SYNC_API_KEY` env variable' if api_key.blank?

    Motor::Configs::SyncWithRemote.call(remote_url, api_key)
    Motor::Configs::WriteToFile.write_with_lock

    puts "✅ Motor Admin configurations have been synced with #{remote_url}"
  rescue Motor::Configs::SyncWithRemote::ApiNotFound
    puts '⚠️  Synchronization failed: you need to specify `MOTOR_SYNC_API_KEY` ' \
         'env variable in your remote app in order to enable this feature'
  end
end
