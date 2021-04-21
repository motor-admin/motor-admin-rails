# frozen_string_literal: true

module Motor
  module ReorderSchema
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

        model.merge(
          columns: sort_by_name(model[:columns], columns_order, sort_alphabetically: false),
          associations: sort_by_name(model[:associations], associations_order),
          actions: sort_by_name(model[:actions], actions_order, sort_alphabetically: false),
          tabs: sort_by_name(model[:tabs], tabs_order, sort_alphabetically: false)
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
          item[:display_name]
        end
      end
    end

    # @return [Hash<String, HashWithIndifferentAccess>]
    def load_configs
      Motor::Config.all.each_with_object({}) do |config, acc|
        acc[config.key] = config.value
      end
    end
  end
end
