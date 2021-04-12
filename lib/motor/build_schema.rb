# frozen_string_literal: true

require_relative './build_schema/load_from_rails'
require_relative './build_schema/find_display_column'
require_relative './build_schema/persist_resource_configs'
require_relative './build_schema/reorder_schema'
require_relative './build_schema/merge_schema_configs'
require_relative './build_schema/utils'

module Motor
  module BuildSchema
    SEARCHABLE_COLUMN_TYPES = %i[citext text string bitstring].freeze

    module_function

    def call
      schema = LoadFromRails.call
      schema = MergeSchemaConfigs.call(schema)

      ReorderSchema.call(schema)
    end
  end
end
