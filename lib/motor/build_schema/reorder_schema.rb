# frozen_string_literal: true

module Motor
  module ReorderSchema
    COLUMNS_DEFAULT_ORDER_WEIGHTS = {
      id: 0,
      updated_at: 2,
      edited_at: 2,
      created_at: 3,
      inserted_at: 3,
      deleted_at: 4,
      archived_at: 4
    }.with_indifferent_access

    COLUMNS_DEFAULT_ORDER_WEIGHT = 1

    module_function

    # @param cache_keys [Hash]
    # @param schema [Array<HashWithIndifferentAccess>]
    # @return [Array<HashWithIndifferentAccess>]
    def call(schema, cache_keys = {})
      configs = load_configs(cache_keys)

      schema = sort_by_name(schema, configs['resources.order'])

      schema.map { |model| reorder_model(model, configs) }
    end

    def reorder_model(model, configs)
      order_configs = build_order_configs(model[:name], configs)

      model.merge(
        columns: sort_by_name(sort_columns(model[:columns]), order_configs[:columns], sort_alphabetically: false),
        associations: sort_by_name(model[:associations], order_configs[:associations]),
        actions: sort_by_name(model[:actions], order_configs[:actions], sort_alphabetically: false),
        tabs: sort_by_name(model[:tabs], order_configs[:tabs], sort_alphabetically: false),
        scopes: sort_by_name(model[:scopes], order_configs[:scopes])
      )
    end

    def build_order_configs(model_name, configs)
      {
        columns: configs["resources.#{model_name}.columns.order"],
        associations: configs["resources.#{model_name}.associations.order"],
        actions: configs["resources.#{model_name}.actions.order"],
        tabs: configs["resources.#{model_name}.tabs.order"],
        scopes: configs["resources.#{model_name}.scopes.order"]
      }
    end

    # @param list [Array<HashWithIndifferentAccess>]
    # @param sort_alphabetically [Boolean]
    # @param order [Array<String>]
    # @return [Array<HashWithIndifferentAccess>]
    def sort_by_name(list, order, sort_alphabetically: true)
      return list if order.blank? && !sort_alphabetically

      list.sort_by do |item|
        if order.present?
          order.index(item[:name]) || Float::MAX
        else
          item[:display_name].to_s
        end
      end
    end

    # @param columns [Array<HashWithIndifferentAccess>]
    # @return [Array<HashWithIndifferentAccess>]
    def sort_columns(columns)
      columns.each_with_object([]) do |column, acc|
        weight = COLUMNS_DEFAULT_ORDER_WEIGHTS.fetch(column[:name], COLUMNS_DEFAULT_ORDER_WEIGHT)

        (acc[weight] ||= []) << column
      end.flatten.compact
    end

    # @param cache_keys [Hash]
    # @return [Hash<String, HashWithIndifferentAccess>]
    def load_configs(cache_keys = {})
      configs = Motor::Configs::LoadFromCache.load_configs(cache_key: cache_keys[:configs])

      configs.each_with_object({}) do |config, acc|
        acc[config.key] = config.value
      end
    end
  end
end
