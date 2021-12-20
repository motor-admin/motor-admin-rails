# frozen_string_literal: true

module Motor
  module Dashboards
    module Persistance
      TitleAlreadyExists = Class.new(StandardError)

      module_function

      def build_from_params(params, current_user = nil)
        dashboard = assign_attributes(Dashboard.new, params)

        dashboard.author = current_user

        dashboard
      end

      def create_from_params!(params, current_user = nil)
        raise TitleAlreadyExists if Dashboard.exists?(title: params[:title])

        dashboard = build_from_params(params, current_user)

        ApplicationRecord.transaction do
          dashboard.save!
        end

        dashboard
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      def update_from_params!(dashboard, params, force_replace: false)
        tag_ids = dashboard.tags.ids

        dashboard = assign_attributes(dashboard, params)

        raise TitleAlreadyExists if !force_replace && title_already_exists?(dashboard)

        ApplicationRecord.transaction do
          archive_with_existing_name(dashboard) if force_replace

          dashboard.save!
        end

        dashboard.touch if tag_ids.sort != dashboard.tags.reload.ids.sort && params[:updated_at].blank?

        dashboard
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      def assign_attributes(dashboard, params)
        dashboard.assign_attributes(params.slice(:title, :description, :preferences))
        dashboard.updated_at = [params[:updated_at], Time.current].min if params[:updated_at].present?

        Motor::Tags.assign_tags(dashboard, params[:tags])
      end

      def archive_with_existing_name(dashboard)
        Motor::Dashboard.where(['title = ? AND id != ?', dashboard.title, dashboard.id])
                        .update_all(deleted_at: Time.current)
      end

      def title_already_exists?(dashboard)
        if dashboard.new_record?
          Motor::Dashboard.exists?(title: dashboard.title, deleted_at: nil)
        else
          Motor::Dashboard.exists?(['title = ? AND id != ? AND deleted_at IS NULL', dashboard.title, dashboard.id])
        end
      end
    end
  end
end
