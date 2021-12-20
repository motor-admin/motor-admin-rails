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
        raise NameAlreadyExists if Alert.exists?(name: params[:name])

        alert = build_from_params(params, current_user)

        raise InvalidInterval unless alert.cron

        ApplicationRecord.transaction do
          alert.save!
        end

        alert
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      def update_from_params!(alert, params, force_replace: false)
        tag_ids = alert.tags.ids

        alert = assign_attributes(alert, params)

        raise NameAlreadyExists if !force_replace && name_already_exists?(alert)
        raise InvalidInterval unless alert.cron

        ApplicationRecord.transaction do
          archive_with_existing_name(alert) if force_replace

          alert.save!
        end

        alert.touch if tags_changed?(tag_ids, alert) && params[:updated_at].blank?

        alert
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      def tags_changed?(previous_ids, alert)
        previous_ids.sort != alert.tags.reload.ids.sort
      end

      def assign_attributes(alert, params)
        alert.assign_attributes(params.slice(*ALERT_ATTRIBUTES))
        alert.preferences[:interval] = normalize_interval(alert.preferences[:interval])
        alert.updated_at = [params[:updated_at], Time.current].min if params[:updated_at].present?

        Motor::Tags.assign_tags(alert, params[:tags])
      end

      def archive_with_existing_name(alert)
        Motor::Alert.where(['name = ? AND id != ?', alert.name, alert.id])
                    .update_all(deleted_at: Time.current)
      end

      def normalize_interval(interval)
        interval.to_s.gsub(NORMALIZE_INTERVAL_REGEXP, 'every ')
      end

      def name_already_exists?(alert)
        if alert.new_record?
          Alert.exists?(name: alert.name, deleted_at: nil)
        else
          Alert.exists?(['name = ? AND id != ? AND deleted_at IS NULL', alert.name, alert.id])
        end
      end
    end
  end
end
