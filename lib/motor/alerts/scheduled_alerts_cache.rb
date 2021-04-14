# frozen_string_literal: true

module Motor
  module Alerts
    module ScheduledAlertsCache
      UPDATE_ALERTS_TASK = Concurrent::TimerTask.new(
        execution_interval: 2.minutes
      ) { Motor::Alerts::ScheduledAlertsCache.load_alerts }

      module_function

      def all
        @all ||= load_alerts
      end

      def load_alerts
        @all = Motor::Alert.all.active.enabled
      end
    end
  end
end
