# frozen_string_literal: true

module Motor
  module Queries
    module Persistance
      NameAlreadyExists = Class.new(StandardError)

      module_function

      def build_from_params(params, current_user = nil)
        query = assign_attributes(Query.new, params)

        query.author = current_user

        query
      end

      def create_from_params!(params, current_user = nil)
        raise NameAlreadyExists if Query.exists?(name: params[:name])

        query = build_from_params(params, current_user)

        ApplicationRecord.transaction do
          query.save!
        end

        query
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      def update_from_params!(query, params, force_replace: false)
        tag_ids = query.tags.ids

        query = assign_attributes(query, params)

        raise NameAlreadyExists if !force_replace && name_already_exists?(query)

        ApplicationRecord.transaction do
          archive_with_existing_name(query) if force_replace

          query.save!
        end

        query.touch if tag_ids.sort != query.tags.reload.ids.sort && params[:updated_at].blank?

        query
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      def assign_attributes(query, params)
        query.assign_attributes(params.slice(:name, :description, :sql_body, :preferences))
        query.updated_at = [params[:updated_at], Time.current].min if params[:updated_at].present?

        Motor::Tags.assign_tags(query, params[:tags])
      end

      def archive_with_existing_name(query)
        Motor::Query.where(['name = ? AND id != ?', query.name, query.id])
                    .update_all(deleted_at: Time.current)
      end

      def name_already_exists?(query)
        if query.new_record?
          Query.exists?(name: query.name)
        else
          Query.exists?(['name = ? AND id != ?', query.name, query.id])
        end
      end
    end
  end
end
