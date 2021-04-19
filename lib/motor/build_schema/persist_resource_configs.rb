# frozen_string_literal: true

module Motor
  module BuildSchema
    module PersistResourceConfigs
      RESOURCE_ATTRS = %w[display_name visible].freeze
      COLUMN_ATTRS = %w[name display_name column_type access_type default_value virtual].freeze
      ASSOCIATION_ATTRS = %w[name display_name visible].freeze
      ACTION_ATTRS = %w[name display_name action_type preferences visible].freeze

      module_function

      # @param resource [Motor::Resource]
      # @return [Motor::Resource]
      def call(resource)
        preferences = resource.preferences

        resource = Motor::Resource.find_or_initialize_by(name: resource.name)

        assign_preferences!(resource, preferences)

        resource.save!

        resource
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      # @param resource [Motor::Resource]
      # @param preferences [HashWithIndifferentAccess]
      # @return [Motor::Resource]
      def assign_preferences!(resource, preferences)
        default_schema = fetch_default_schema(resource.name)

        resource.preferences = normalize_preferences(
          default_schema,
          resource.preferences,
          preferences
        )

        resource
      end

      # @param default_prefs [HashWithIndifferentAccess]
      # @param existing_prefs [HashWithIndifferentAccess]
      # @param new_prefs [HashWithIndifferentAccess]
      # @return [HashWithIndifferentAccess]
      def normalize_preferences(default_prefs, existing_prefs, new_prefs)
        normalized_preferences = new_prefs.slice(*RESOURCE_ATTRS).with_indifferent_access
        normalized_preferences = existing_prefs.merge(normalized_preferences)
        normalized_preferences = reject_default(default_prefs, normalized_preferences)

        if new_prefs[:columns].present?
          normalized_preferences[:columns] = normalize_columns(
            default_prefs[:columns],
            existing_prefs.fetch(:columns, []),
            new_prefs.fetch(:columns, [])
          )
        end

        if new_prefs[:associations].present?
          normalized_preferences[:associations] = normalize_associations(
            default_prefs[:associations],
            existing_prefs.fetch(:associations, []),
            new_prefs.fetch(:associations, [])
          )
        end

        if new_prefs[:actions].present?
          normalized_preferences[:actions] = normalize_actions(
            default_prefs[:actions],
            existing_prefs.fetch(:actions, []),
            new_prefs.fetch(:actions, [])
          )
        end

        normalized_preferences.compact
      end

      # @param default_columns [Array<HashWithIndifferentAccess>]
      # @param existing_columns [Array<HashWithIndifferentAccess>]
      # @param new_columns [Array<HashWithIndifferentAccess>]
      # @return [Array<HashWithIndifferentAccess>]
      def normalize_columns(default_columns, existing_columns, new_columns)
        (existing_columns.pluck(:name) + new_columns.pluck(:name)).uniq.map do |name|
          new_column = safe_fetch_by_name(new_columns, name)

          next if new_column[:_remove]

          existing_column = safe_fetch_by_name(existing_columns, name)
          default_column = safe_fetch_by_name(default_columns, name)
          column_attrs = new_column.slice(*COLUMN_ATTRS)

          normalized_column = existing_column.merge(column_attrs)
          normalized_column = reject_default(default_column, normalized_column)

          normalized_column.merge(name: name) if normalized_column.present?
        end.compact.presence
      end

      # @param default_actions [Array<HashWithIndifferentAccess>]
      # @param existing_actions [Array<HashWithIndifferentAccess>]
      # @param new_actions [Array<HashWithIndifferentAccess>]
      # @return [Array<HashWithIndifferentAccess>]
      def normalize_actions(default_actions, existing_actions, new_actions)
        (existing_actions.pluck(:name) + new_actions.pluck(:name)).uniq.map do |name|
          new_action = safe_fetch_by_name(new_actions, name)

          next if new_action[:_remove]

          existing_action = safe_fetch_by_name(existing_actions, name)
          default_action = safe_fetch_by_name(default_actions, name)
          action_attrs = new_action.slice(*ACTION_ATTRS)

          normalized_action = existing_action.merge(action_attrs)
          normalized_action = reject_default(default_action, normalized_action)

          normalized_action.merge(name: name) if normalized_action.present?
        end.compact.presence
      end

      # @param default_assocs [Array<HashWithIndifferentAccess>]
      # @param existing_assocs [Array<HashWithIndifferentAccess>]
      # @param new_assocs [Array<HashWithIndifferentAccess>]
      # @return [Array<HashWithIndifferentAccess>]
      def normalize_associations(default_assocs, existing_assocs, new_assocs)
        (existing_assocs.pluck(:name) + new_assocs.pluck(:name)).uniq.map do |name|
          new_assoc = safe_fetch_by_name(new_assocs, name)
          existing_assoc = safe_fetch_by_name(existing_assocs, name)
          default_assoc = safe_fetch_by_name(default_assocs, name)
          assoc_attrs = new_assoc.slice(*ASSOCIATION_ATTRS)

          normalized_assoc = existing_assoc.merge(assoc_attrs)
          normalized_assoc = reject_default(default_assoc, normalized_assoc)

          normalized_assoc.merge(name: name) if normalized_assoc.present?
        end.compact.presence
      end

      def safe_fetch_by_name(list, name)
        list.find { |e| e[:name] == name } || {}
      end

      # @param resource_name [String]
      # @return [HashWithIndifferentAccess]
      def fetch_default_schema(resource_name)
        LoadFromRails.build_model_schema(resource_name.classify.constantize)
      end

      # @param default [HashWithIndifferentAccess]
      # @param new [HashWithIndifferentAccess]
      # @return [HashWithIndifferentAccess]
      def reject_default(default, new)
        return new unless default

        new.reject do |key, value|
          default[key].to_json == value.to_json
        end
      end
    end
  end
end
