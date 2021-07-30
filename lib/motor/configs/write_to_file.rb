# frozen_string_literal: true

module Motor
  module Configs
    module WriteToFile
      THREAD_POOL = Concurrent::FixedThreadPool.new(1)

      module_function

      def call
        return if Rails.env.test?
        return if THREAD_POOL.queue_length.positive?

        THREAD_POOL.post do
          ActiveRecord::Base.logger.silence do
            write_with_lock
          end
        rescue StandardError => e
          Rails.logger.error(e)
        end
      end

      def write_with_lock
        File.open(Motor::Configs.file_path, 'w') do |file|
          file.flock(File::LOCK_EX)

          YAML.dump(Motor::Configs::BuildConfigsHash.call, file)

          file.flock(File::LOCK_UN)

          file
        end.close
      end
    end
  end
end
