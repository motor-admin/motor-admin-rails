# frozen_string_literal: true

module Motor
  module BuildSchema
    ACTIVE_STORAGE_ATTACHMENT_SCHEMA = {
      name: 'active_storage/attachment',
      slug: 'active_storage__attachments',
      table_name: 'active_storage_attachments',
      primary_key: 'id',
      display_name: 'Attachments',
      display_column: 'filename',
      columns: [
        {
          name: 'id',
          display_name: 'Id',
          column_type: 'integer',
          access_type: 'read_only',
          default_value: nil,
          validators: [],
          virtual: false
        },
        {
          name: 'path',
          display_name: 'Path',
          column_type: 'string',
          access_type: 'read_only',
          default_value: nil,
          validators: [],
          virtual: false
        },
        {
          name: 'name',
          display_name: 'Name',
          column_type: 'string',
          access_type: 'read_write',
          default_value: nil,
          validators: [],
          virtual: false
        },
        {
          name: 'record_type',
          display_name: 'Record type',
          column_type: 'string',
          access_type: 'read_write',
          default_value: nil,
          validators: [],
          virtual: false
        },
        {
          name: 'record_id',
          display_name: 'Record',
          column_type: 'integer',
          access_type: 'read_write',
          default_value: nil,
          validators: [],
          virtual: false
        },
        {
          name: 'file',
          display_name: 'File',
          column_type: 'file',
          access_type: 'write_only',
          default_value: nil,
          validators: [],
          virtual: false
        },
        {
          name: 'created_at',
          display_name: 'Created at',
          column_type: 'datetime',
          access_type: 'read_only',
          default_value: nil,
          validators: [],
          virtual: false
        }
      ],
      associations: [],
      scopes: [],
      actions: Motor::BuildSchema::DEFAULT_ACTIONS.reject { |e| e[:name] == 'edit' },
      tabs: Motor::BuildSchema::DEFAULT_TABS,
      visible: true
    }.with_indifferent_access
  end
end
