# frozen_string_literal: true

module Motor
  module Resources
    module PersistConfigs
      COLUMN_DEFAULTS = BuildSchema::COLUMN_DEFAULTS
      ACTION_DEFAULTS = BuildSchema::ACTION_DEFAULTS
      TAB_DEFAULTS = BuildSchema::TAB_DEFAULTS
      SCOPE_DEFAULTS = BuildSchema::SCOPE_DEFAULTS
      ASSOCIATION_DEFAULTS = BuildSchema::ASSOCIATION_DEFAULTS

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

        normalize_configs!(normalized_preferences, :columns, default_prefs, existing_prefs, new_prefs)
        normalize_configs!(normalized_preferences, :associations, default_prefs, existing_prefs, new_prefs)
        normalize_configs!(normalized_preferences, :actions, default_prefs, existing_prefs, new_prefs)
        normalize_configs!(normalized_preferences, :tabs, default_prefs, existing_prefs, new_prefs)
        normalize_configs!(normalized_preferences, :scopes, default_prefs, existing_prefs, new_prefs)

        normalized_preferences.compact
      end

      def normalize_configs!(preferences, configs_name, default_prefs, existing_prefs, new_prefs)
        return preferences if new_prefs[configs_name].blank?

        normalized_configs = public_send("normalize_#{configs_name}",
                                         default_prefs[configs_name],
                                         existing_prefs.fetch(configs_name, []),
                                         new_prefs.fetch(configs_name, []))

        preferences[configs_name] = normalized_configs

        preferences
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

          next if new_assoc[:_remove]

          existing_assoc = safe_fetch_by_name(existing_assocs, name)
          default_assoc = safe_fetch_by_name(default_assocs, name)
          assoc_attrs = new_assoc.slice(*ASSOCIATION_ATTRS)

          normalized_assoc = existing_assoc.merge(assoc_attrs)
          normalized_assoc = reject_default(default_assoc.presence || ASSOCIATION_DEFAULTS, normalized_assoc)

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
        model = resource_name.classify.constantize

        BuildSchema::LoadFromRails.build_model_schema(model).merge(custom_sql: model.all.to_sql)
      end

      # @param default [HashWithIndifferentAccess]
      # @param new [HashWithIndifferentAccess]
      # @return [HashWithIndifferentAccess]
      def reject_default(default, new)
        return new unless default

        new.reject do |key, value|
          default[key].to_json ==
            if value.is_a?(Hash) || value.is_a?(ActiveSupport::HashWithIndifferentAccess)
              value.select { |_, v| v.present? }.to_json
            else
              value.to_json
            end
        end
      end
    end
  end
end
