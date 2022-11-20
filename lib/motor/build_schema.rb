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

    module ColumnTypes
      ALL = [
        STRING = 'string',
        INTEGER = 'integer',
        FLOAT = 'float',
        REFERENCE = 'reference',
        DATETIME = 'datetime',
        DATE = 'date',
        BOOLEAN = 'boolean',
        TEXTAREA = 'textarea',
        RICHTEXT = 'richtext',
        CURRENCY = 'currency',
        PERCENTAGE = 'percentage',
        CHANGE = 'change',
        CHART = 'chart',
        TAG = 'tag',
        LINK = 'link',
        COLOR = 'color',
        IMAGE = 'image',
        FILE = 'file',
        JSON = 'json'
      ].freeze
    end

    module ColumnSources
      ALL = [
        TABLE = 'table',
        QUERY = 'query',
        REFLECTION = 'reflection'
      ].freeze
    end

    SEARCHABLE_COLUMN_TYPES = %i[citext text string bitstring].freeze

    DEFAULT_TYPE = 'default'
    DEFAULT_ICON = 'database'

    COLUMN_NAME_ACCESS_TYPES = {
      id: ColumnAccessTypes::READ_ONLY,
      created_at: ColumnAccessTypes::READ_ONLY,
      created_on: ColumnAccessTypes::READ_ONLY,
      inserted_at: ColumnAccessTypes::READ_ONLY,
      updated_at: ColumnAccessTypes::READ_ONLY,
      updated_on: ColumnAccessTypes::READ_ONLY,
      modified_at: ColumnAccessTypes::READ_ONLY,
      deleted_at: ColumnAccessTypes::READ_ONLY
    }.with_indifferent_access.freeze

    COLUMN_DEFAULTS = {
      access_type: ColumnAccessTypes::READ_WRITE,
      column_source: ColumnSources::TABLE,
      default_value: nil,
      reference: nil,
      format: {},
      validators: [],
      description: ''
    }.with_indifferent_access

    ACTION_DEFAULTS = {
      visible: true,
      apply_on: 'member',
      preferences: {}
    }.with_indifferent_access

    TAB_DEFAULTS = {
      visible: true,
      tab_type: DEFAULT_TYPE,
      preferences: {}
    }.with_indifferent_access

    SCOPE_DEFAULTS = {
      visible: true,
      scope_type: DEFAULT_TYPE,
      preferences: {}
    }.with_indifferent_access

    ASSOCIATION_DEFAULTS = {
      visible: true,
      icon: DEFAULT_ICON,
      options: {}
    }.with_indifferent_access

    module_function

    def call(cache_keys = {}, current_ability = nil)
      schema = LoadFromRails.call
      schema = MergeSchemaConfigs.call(schema, cache_keys)
      schema = ApplyPermissions.call(schema, current_ability) if current_ability

      ReorderSchema.call(schema, cache_keys)
    end

    def for_model(model)
      schema = Motor::BuildSchema::LoadFromRails.build_model_schema(model)
      configs = Motor::Resource.find_by(name: schema[:name]).preferences

      MergeSchemaConfigs.merge_model(schema, configs)
    end
  end
end

require_relative './build_schema/active_storage_attachment_schema'
require_relative './build_schema/adjust_devise_model_schema'
require_relative './build_schema/load_from_rails'
require_relative './build_schema/find_display_column'
require_relative './build_schema/find_icon'
require_relative './build_schema/reorder_schema'
require_relative './build_schema/merge_schema_configs'
require_relative './build_schema/apply_permissions'
require_relative './build_schema/utils'
require_relative './build_schema/defaults'
require_relative './build_schema/find_searchable_columns'
