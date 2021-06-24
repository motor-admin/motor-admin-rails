# frozen_string_literal: true

module Motor
  module BuildSchema
    module ColumnAccessTypes
      ALL = [
        READ_ONLY = 'read_only',
        WRITE_ONLY = 'write_only',
        READ_WRITE = 'read_write',
        HIDDEN = 'hidden'
      ].freeze
    end

    SEARCHABLE_COLUMN_TYPES = %i[citext text string bitstring].freeze

    COLUMN_NAME_ACCESS_TYPES = {
      id: ColumnAccessTypes::READ_ONLY,
      created_at: ColumnAccessTypes::READ_ONLY,
      updated_at: ColumnAccessTypes::READ_ONLY,
      deleted_at: ColumnAccessTypes::READ_ONLY
    }.with_indifferent_access.freeze

    DEFAULT_SCOPE_TYPE = 'default'

    module_function

    def call(cache_keys = {}, current_ability = nil)
      schema = LoadFromRails.call
      schema = MergeSchemaConfigs.call(schema, cache_keys)
      schema = ApplyPermissions.call(schema, current_ability) if current_ability

      ReorderSchema.call(schema, cache_keys)
    end
  end
end

require_relative './build_schema/active_storage_attachment_schema'
require_relative './build_schema/adjust_devise_model_schema'
require_relative './build_schema/load_from_rails'
require_relative './build_schema/find_display_column'
require_relative './build_schema/find_icon'
require_relative './build_schema/persist_resource_configs'
require_relative './build_schema/reorder_schema'
require_relative './build_schema/merge_schema_configs'
require_relative './build_schema/apply_permissions'
require_relative './build_schema/utils'
require_relative './build_schema/defaults'
