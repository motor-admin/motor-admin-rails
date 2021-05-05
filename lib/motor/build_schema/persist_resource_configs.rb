# frozen_string_literal: true

module Motor
  module BuildSchema
    module PersistResourceConfigs
      RESOURCE_ATTRS = %w[display_name visible].freeze
      COLUMN_ATTRS = %w[name display_name column_type access_type default_value virtual format].freeze
      ASSOCIATION_ATTRS = %w[name display_name visible].freeze
      SCOPE_ATTRS = %w[name display_name scope_type preferences visible].freeze
      ACTION_ATTRS = %w[name display_name action_type preferences visible].freeze
      TAB_ATTRS = %w[name display_name tab_type preferences visible].freeze

      COLUMN_DEFAULTS = {
        access_type: 'read_write',
        default_value: nil,
        reference: nil,
        format: {},
        validators: []
      }.with_indifferent_access

      ACTION_DEFAULTS = {
        visible: true,
        preferences: {}
      }.with_indifferent_access

      TAB_DEFAULTS = {
        visible: true,
        tab_type: 'default',
        preferences: {}
      }.with_indifferent_access

      SCOPE_DEFAULTS = {
        visible: true,
        scope_type: 'default',
        preferences: {}
      }.with_indifferent_access

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

        if new_prefs[:tabs].present?
          normalized_preferences[:tabs] = normalize_tabs(
            default_prefs[:tabs],
            existing_prefs.fetch(:tabs, []),
            new_prefs.fetch(:tabs, [])
          )
        end

        if new_prefs[:scopes].present?
          normalized_preferences[:scopes] = normalize_scopes(
            default_prefs[:scopes],
            existing_prefs.fetch(:scopes, []),
            new_prefs.fetch(:scopes, [])
          )
        end

        normalized_preferences.compact
      end

      # @param default_columns [Array<HashWithIndifferentAccess>]
      # @param existing_columns [Array<HashWithIndifferentAccess>]
      # @param new_columns [Array<HashWithIndifferentAccess>]
      # @return [Array<HashWithIndifferentAccess>]
      def normalize_columns(default_columns, existing_columns, new_columns)
        fetch_update_names(existing_columns, new_columns).uniq.map do |name|
          new_column = safe_fetch_by_name(new_columns, name)

          next if new_column[:_remove]

          existing_column = safe_fetch_by_name(existing_columns, name)
          default_column = safe_fetch_by_name(default_columns, name)
          column_attrs = new_column.slice(*COLUMN_ATTRS)

          normalized_column = existing_column.merge(column_attrs)
          normalized_column = reject_default(default_column, normalized_column)

          next if normalized_column.blank?

          normalized_column[:name] ||= name

          normalized_column
        end.compact.presence
      end

      # @param default_actions [Array<HashWithIndifferentAccess>]
      # @param existing_actions [Array<HashWithIndifferentAccess>]
      # @param new_actions [Array<HashWithIndifferentAccess>]
      # @return [Array<HashWithIndifferentAccess>]
      def normalize_actions(default_actions, existing_actions, new_actions)
        fetch_update_names(existing_actions, new_actions).map do |name|
          new_action = safe_fetch_by_name(new_actions, name)

          next if new_action[:_remove]

          existing_action = safe_fetch_by_name(existing_actions, name)
          default_action = safe_fetch_by_name(default_actions, name)
          action_attrs = new_action.slice(*ACTION_ATTRS)

          normalized_action = existing_action.merge(action_attrs)
          normalized_action = reject_default(default_action.presence || ACTION_DEFAULTS, normalized_action)

          next if normalized_action.blank?

          normalized_action[:name] ||= name

          normalized_action
        end.compact.presence
      end

      # @param default_tabs [Array<HashWithIndifferentAccess>]
      # @param existing_tabs [Array<HashWithIndifferentAccess>]
      # @param new_tabs [Array<HashWithIndifferentAccess>]
      # @return [Array<HashWithIndifferentAccess>]
      def normalize_tabs(default_tabs, existing_tabs, new_tabs)
        fetch_update_names(existing_tabs, new_tabs).uniq.map do |name|
          new_tab = safe_fetch_by_name(new_tabs, name)

          next if new_tab[:_remove]

          existing_tab = safe_fetch_by_name(existing_tabs, name)
          default_tab = safe_fetch_by_name(default_tabs, name)
          tab_attrs = new_tab.slice(*TAB_ATTRS)

          normalized_tab = existing_tab.merge(tab_attrs)
          normalized_tab = reject_default(default_tab.presence || TAB_DEFAULTS, normalized_tab)

          next if normalized_tab.blank?

          normalized_tab[:name] ||= name

          normalized_tab
        end.compact.presence
      end

      # @param default_scopes [Array<HashWithIndifferentAccess>]
      # @param existing_scopes [Array<HashWithIndifferentAccess>]
      # @param new_scopes [Array<HashWithIndifferentAccess>]
      # @return [Array<HashWithIndifferentAccess>]
      def normalize_scopes(default_scopes, existing_scopes, new_scopes)
        fetch_update_names(existing_scopes, new_scopes).uniq.map do |name|
          new_scope = safe_fetch_by_name(new_scopes, name)

          next if new_scope[:_remove]

          existing_scope = safe_fetch_by_name(existing_scopes, name)
          default_scope = safe_fetch_by_name(default_scopes, name)
          scope_attrs = new_scope.slice(*SCOPE_ATTRS)

          normalized_scope = existing_scope.merge(scope_attrs)
          normalized_scope = reject_default(default_scope.presence || SCOPE_DEFAULTS, normalized_scope)

          next if normalized_scope.blank?

          normalized_scope[:name] ||= name

          normalized_scope
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

      def fetch_update_names(existing_items, new_items)
        new_names = new_items.map { |e| e[:_update] || e[:name] }

        (existing_items.pluck(:name) + new_names).uniq
      end

      def safe_fetch_by_name(list, name)
        list.find { |e| e[:_update] == name || e[:name] == name } || {}
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
