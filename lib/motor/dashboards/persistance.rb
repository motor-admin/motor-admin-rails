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
        raise TitleAlreadyExists if Dashboard.exists?(['lower(title) = ?', params[:title].to_s.downcase])

        dashboard = build_from_params(params, current_user)

        ApplicationRecord.transaction do
          dashboard.save!
        end

        dashboard
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      def update_from_params!(dashboard, params)
        raise TitleAlreadyExists if title_already_exists?(dashboard)

        dashboard = assign_attributes(dashboard, params)

        ApplicationRecord.transaction do
          dashboard.save!
        end

        dashboard
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      def assign_attributes(dashboard, params)
        dashboard.assign_attributes(params.slice(:title, :description, :preferences))

        Motor::Tags.assign_tags(dashboard, params[:tags])
      end

      def title_already_exists?(dashboard)
        if dashboard.new_record?
          Dashboard.exists?(['lower(title) = ?', dashboard.title.to_s.downcase])
        else
          Dashboard.exists?(['lower(title) = ? AND id != ?', dashboard.title.to_s.downcase, dashboard.id])
        end
      end
    end
  end
end
