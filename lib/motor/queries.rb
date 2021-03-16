# frozen_string_literal: true

require_relative './queries/run_query'
require_relative './queries/postgresql_exec_query'

module Motor
  module Queries
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
      raise NameAlreadyExists if name_already_exists?(query)

      query = assign_attributes(query, params)

      ApplicationRecord.transaction do
        query.save!
      end

      query
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def assign_attributes(query, params)
      query.assign_attributes(params.slice(:name, :sql_body, :preferences))

      assign_tags(query, params[:tags])
    end

    def assign_tags(query, tags)
      return query unless tags

      tags.each do |tag_name|
        next if query.taggable_tags.find { |tt| tt.tag.name.downcase == tag_name.downcase }

        tag = Tag.where('lower(name) = ?', tag_name.downcase).take || Tag.new(name: tag_name)

        query.taggable_tags.new(tag: tag)
      end

      remove_missing_tags(query, tags) if query.persisted?

      query
    end

    def remove_missing_tags(query, tags)
      tags_to_remove = query.tags.reject { |tt| tt.name.downcase.in?(tags) }

      query.tags -= tags_to_remove

      query
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
