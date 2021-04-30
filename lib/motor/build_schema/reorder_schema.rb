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

    # @param schema [Array<HashWithIndifferentAccess>]
    # @return [Array<HashWithIndifferentAccess>]
    def call(schema)
      configs = load_configs

      schema = sort_by_name(schema, configs['resources.order'])

      schema.map do |model|
        columns_order = configs["resources.#{model[:name]}.columns.order"]
        associations_order = configs["resources.#{model[:name]}.associations.order"]
        actions_order = configs["resources.#{model[:name]}.actions.order"]
        tabs_order = configs["resources.#{model[:name]}.tabs.order"]
        scopes_order = configs["resources.#{model[:name]}.scopes.order"]

        model.merge(
          columns: sort_by_name(sort_columns(model[:columns]), columns_order, sort_alphabetically: false),
          associations: sort_by_name(model[:associations], associations_order),
          actions: sort_by_name(model[:actions], actions_order, sort_alphabetically: false),
          tabs: sort_by_name(model[:tabs], tabs_order, sort_alphabetically: false),
          scopes: sort_by_name(model[:scopes], scopes_order)
        )
      end
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

    def sort_columns(columns)
      columns.each_with_object([]) do |column, acc|
        weight = COLUMNS_DEFAULT_ORDER_WEIGHTS.fetch(column[:name], COLUMNS_DEFAULT_ORDER_WEIGHT)

        (acc[weight] ||= []) << column
      end.flatten.compact
    end

    # @return [Hash<String, HashWithIndifferentAccess>]
    def load_configs
      Motor::Config.all.each_with_object({}) do |config, acc|
        acc[config.key] = config.value
      end
    end
  end
end
