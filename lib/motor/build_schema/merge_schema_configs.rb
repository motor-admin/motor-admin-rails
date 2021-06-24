# frozen_string_literal: true

module Motor
  module BuildSchema
    module MergeSchemaConfigs
      RESOURCE_ATTRS = PersistResourceConfigs::RESOURCE_ATTRS
      COLUMN_DEFAULTS = PersistResourceConfigs::COLUMN_DEFAULTS
      ACTION_DEFAULTS = PersistResourceConfigs::ACTION_DEFAULTS
      TAB_DEFAULTS = PersistResourceConfigs::TAB_DEFAULTS
      SCOPE_DEFAULTS = PersistResourceConfigs::SCOPE_DEFAULTS

      module_function

      # @param schema [Array<HashWithIndifferentAccess>]
      # @param cache_keys [Hash]
      # @return [Array<HashWithIndifferentAccess>]
      def call(schema, cache_keys = {})
        configs = load_configs(cache_keys)

        schema.map do |model|
          merge_model(model, configs.fetch(model[:name], {}))
        end
      end

      # @param model [HashWithIndifferentAccess]
      # @param configs [HashWithIndifferentAccess]
      # @return [HashWithIndifferentAccess]
      def merge_model(model, configs)
        updated_model = model.merge(configs.slice(*RESOURCE_ATTRS))

        merge_actions!(updated_model, configs)
        merge_associations!(updated_model, configs)
        merge_columns!(updated_model, configs)
        merge_tabs!(updated_model, configs)
        merge_scopes!(updated_model, configs)

        updated_model
      end

      # @param model [HashWithIndifferentAccess]
      # @param configs [HashWithIndifferentAccess]
      # @return [HashWithIndifferentAccess]
      def merge_associations!(model, configs)
        model[:associations] = merge_by_name(
          model[:associations],
          configs[:associations],
          {},
          ->(_) { true }
        )

        model
      end

      # @param model [HashWithIndifferentAccess]
      # @param configs [HashWithIndifferentAccess]
      # @return [HashWithIndifferentAccess]
      def merge_columns!(model, configs)
        model[:columns] = merge_by_name(
          model[:columns],
          configs[:columns],
          COLUMN_DEFAULTS,
          ->(scope) { !scope[:virtual] }
        )

        model
      end

      # @param model [HashWithIndifferentAccess]
      # @param configs [HashWithIndifferentAccess]
      # @return [HashWithIndifferentAccess]
      def merge_actions!(model, configs)
        model[:actions] = merge_by_name(
          model[:actions],
          configs[:actions],
          ACTION_DEFAULTS
        )

        model
      end

      # @param model [HashWithIndifferentAccess]
      # @param configs [HashWithIndifferentAccess]
      # @return [HashWithIndifferentAccess]
      def merge_tabs!(model, configs)
        model[:tabs] = merge_by_name(
          model[:tabs],
          configs[:tabs],
          TAB_DEFAULTS
        )

        model
      end

      # @param model [HashWithIndifferentAccess]
      # @param configs [HashWithIndifferentAccess]
      # @return [HashWithIndifferentAccess]
      def merge_scopes!(model, configs)
        model[:scopes] = merge_by_name(
          model[:scopes],
          configs[:scopes],
          SCOPE_DEFAULTS,
          ->(scope) { scope[:scope_type] != 'filter' }
        )

        model
      end

      # @param defaults [Array<HashWithIndifferentAccess>]
      # @param configs [Array<HashWithIndifferentAccess>]
      # @return [Array<HashWithIndifferentAccess>]
      def merge_by_name(defaults, configs, default_attrs = {}, default_item_check = nil)
        return defaults if configs.blank?

        (defaults.pluck(:name) + configs.pluck(:name)).uniq.map do |name|
          config_item = configs.find { |e| e[:name] == name }
          default_item = defaults.find { |e| e[:name] == name }

          next if default_item.nil? && default_item_check&.call(config_item)

          (default_item || default_attrs).merge(config_item || {})
        end.compact
      end

      # @param cache_keys [Hash]
      # @return [HashWithIndifferentAccess<String, HashWithIndifferentAccess>]
      def load_configs(cache_keys)
        resources = Motor::Configs::LoadFromCache.load_resources(cache_key: cache_keys[:resources])

        resources.each_with_object(HashWithIndifferentAccess.new) do |resource, acc|
          acc[resource.name] = resource.preferences
        end
      end
    end
  end
end
