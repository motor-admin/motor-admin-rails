# frozen_string_literal: true

module Motor
  module Alerts
    module Persistance
      ALERT_ATTRIBUTES = %i[
        query_id
        name
        description
        preferences
        is_enabled
        to_emails
      ].freeze

      NameAlreadyExists = Class.new(StandardError)
      InvalidInterval = Class.new(StandardError)

      NORMALIZE_INTERVAL_REGEXP = /\A(?:every\s+)?/i.freeze

      module_function

      def build_from_params(params, current_user = nil)
        alert = assign_attributes(Alert.new, params)

        alert.author = current_user

        alert
      end

      def create_from_params!(params, current_user = nil)
        raise NameAlreadyExists if Alert.exists?(['lower(name) = ?', params[:name].to_s.downcase])

        alert = build_from_params(params, current_user)

        raise InvalidInterval unless alert.cron

        ApplicationRecord.transaction do
          alert.save!
        end

        alert
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      def update_from_params!(alert, params)
        alert = assign_attributes(alert, params)

        raise NameAlreadyExists if name_already_exists?(alert)
        raise InvalidInterval unless alert.cron

        ApplicationRecord.transaction do
          alert.save!
        end

        alert.tags.reload

        alert
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      def assign_attributes(alert, params)
        alert.assign_attributes(params.slice(*ALERT_ATTRIBUTES))
        alert.preferences[:interval] = normalize_interval(alert.preferences[:interval])

        Motor::Tags.assign_tags(alert, params[:tags])
      end

      def normalize_interval(interval)
        interval.to_s.gsub(NORMALIZE_INTERVAL_REGEXP, 'every ')
      end

      def name_already_exists?(alert)
        if alert.new_record?
          Alert.exists?(['lower(name) = ?', alert.name.to_s.downcase])
        else
          Alert.exists?(['lower(name) = ? AND id != ?', alert.name.to_s.downcase, alert.id])
        end
      end
    end
  end
end
