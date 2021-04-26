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
        raise NameAlreadyExists if Query.exists?(['lower(name) = ?', params[:name].to_s.downcase])

        query = build_from_params(params, current_user)

        ApplicationRecord.transaction do
          query.save!
        end

        query
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      def update_from_params!(query, params)
        query = assign_attributes(query, params)

        raise NameAlreadyExists if name_already_exists?(query)

        ApplicationRecord.transaction do
          query.save!
        end

        query.tags.reload

        query
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      def assign_attributes(query, params)
        query.assign_attributes(params.slice(:name, :description, :sql_body, :preferences))

        Motor::Tags.assign_tags(query, params[:tags])
      end

      def name_already_exists?(query)
        if query.new_record?
          Query.exists?(['lower(name) = ?', query.name.to_s.downcase])
        else
          Query.exists?(['lower(name) = ? AND id != ?', query.name.to_s.downcase, query.id])
        end
      end
    end
  end
end
