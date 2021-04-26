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
      # @return [Array<HashWithIndifferentAccess>]
      def call(schema)
        configs = load_configs

        schema.map do |model|
          merge_model(model, configs.fetch(model[:name], {}))
        end
      end

      # @param model [HashWithIndifferentAccess]
      # @param configs [HashWithIndifferentAccess]
      # @return [HashWithIndifferentAccess]
      def merge_model(model, configs)
        updated_model = model.merge(configs.slice(*RESOURCE_ATTRS))

        updated_model[:associations] = merge_by_name(
          model[:associations],
          configs[:associations]
        )

        updated_model[:columns] = merge_by_name(
          model[:columns],
          configs[:columns],
          COLUMN_DEFAULTS
        )

        updated_model[:actions] = merge_by_name(
          model[:actions],
          configs[:actions],
          ACTION_DEFAULTS
        )

        updated_model[:tabs] = merge_by_name(
          model[:tabs],
          configs[:tabs],
          TAB_DEFAULTS
        )

        updated_model[:scopes] = merge_by_name(
          model[:scopes],
          configs[:scopes],
          SCOPE_DEFAULTS
        )

        updated_model
      end

      # @param defaults [Array<HashWithIndifferentAccess>]
      # @param configs [Array<HashWithIndifferentAccess>]
      # @return [Array<HashWithIndifferentAccess>]
      def merge_by_name(defaults, configs, default_attrs = {})
        return defaults if configs.blank?

        (defaults.pluck(:name) + configs.pluck(:name)).uniq.map do |name|
          config_item = configs.find { |e| e[:name] == name } || {}
          default_item = defaults.find { |e| e[:name] == name } || default_attrs

          default_item.merge(config_item)
        end
      end

      # @return [HashWithIndifferentAccess<String, HashWithIndifferentAccess>]
      def load_configs
        Motor::Resource.all.each_with_object(HashWithIndifferentAccess.new) do |resource, acc|
          acc[resource.name] = resource.preferences
        end
      end
    end
  end
end
