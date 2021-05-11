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

    DEFAULT_ACTIONS = [
      {
        name: 'create',
        display_name: 'Create',
        action_type: 'default',
        preferences: {},
        visible: true
      },
      {
        name: 'edit',
        display_name: 'Edit',
        action_type: 'default',
        preferences: {},
        visible: true
      },
      {
        name: 'remove',
        display_name: 'Remove',
        action_type: 'default',
        preferences: {},
        visible: true
      }
    ].freeze

    DEFAULT_TABS = [
      {
        name: 'details',
        display_name: 'Details',
        tab_type: 'default',
        preferences: {},
        visible: true
      }
    ].freeze

    module_function

    def call
      schema = LoadFromRails.call
      schema = MergeSchemaConfigs.call(schema)

      ReorderSchema.call(schema)
    end
  end
end

require_relative './build_schema/active_storage_attachment_schema'
require_relative './build_schema/load_from_rails'
require_relative './build_schema/find_display_column'
require_relative './build_schema/persist_resource_configs'
require_relative './build_schema/reorder_schema'
require_relative './build_schema/merge_schema_configs'
require_relative './build_schema/utils'
