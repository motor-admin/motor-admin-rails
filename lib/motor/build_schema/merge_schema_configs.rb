# frozen_string_literal: true

module Motor
  module BuildSchema
    module MergeSchemaConfigs
      RESOURCE_ATTRS = PersistResourceConfigs::RESOURCE_ATTRS

      COLUMN_DEFAULTS = {
        access_type: 'read_write',
        default_value: nil,
        validators: []
      }.with_indifferent_access

      module_function

      # @param schema [Array<HashWithIndifferentAccess>]
      # @return [Array<HashWithIndifferentAccess>]
      def call(schema)
        configs = load_configs

        schema.map do |model|
          updated_model = model.merge(
            configs.fetch(model[:name], {}).slice(*RESOURCE_ATTRS)
          )

          updated_model[:columns] = merge_by_name(
            model[:columns],
            configs.dig(model[:name], :columns),
            COLUMN_DEFAULTS
          )

          updated_model[:associations] = merge_by_name(
            model[:associations],
            configs.dig(model[:name], :associations)
          )

          updated_model
        end
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
