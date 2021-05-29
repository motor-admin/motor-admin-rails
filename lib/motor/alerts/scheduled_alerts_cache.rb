# frozen_string_literal: true

module Motor
  module Alerts
    module ScheduledAlertsCache
      CACHE_STORE = ActiveSupport::Cache::MemoryStore.new(size: 5.megabytes)

      module_function

      def all
        ActiveRecord::Base.logger.silence do
          CACHE_STORE.fetch(Motor::Alert.all.maximum(:updated_at)) do
            clear

            Motor::Alert.all.active.enabled.to_a
          end
        end
      end

      def clear
        CACHE_STORE.clear
      end
    end
  end
end
