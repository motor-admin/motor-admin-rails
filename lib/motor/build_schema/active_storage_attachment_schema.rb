# frozen_string_literal: true

module Motor
  module BuildSchema
    module ActiveStorageAttachmentSchema
      module_function

      # rubocop:disable Metrics/MethodLength
      def call
        model = ActiveStorage::Attachment

        {
          name: model.name.underscore,
          slug: Utils.slugify(model),
          class_name: model.name,
          table_name: model.table_name,
          primary_key: model.primary_key,
          display_name: model.model_name.human(count: 2, default: 'Attachments'),
          display_column: 'id',
          icon: 'paperclip',
          columns: [
            {
              name: 'id',
              display_name: 'ID',
              column_type: 'integer',
              access_type: 'read_only',
              default_value: nil,
              validators: [],
              format: {},
              is_array: false,
              reference: nil,
              virtual: false
            },
            {
              name: 'path',
              display_name: model.human_attribute_name(:path),
              column_type: 'string',
              access_type: 'read_only',
              default_value: nil,
              validators: [],
              format: {},
              is_array: false,
              reference: nil,
              virtual: true
            },
            {
              name: 'name',
              display_name: model.human_attribute_name(:name),
              column_type: 'string',
              access_type: 'read_write',
              default_value: nil,
              validators: [],
              format: {},
              is_array: false,
              reference: nil,
              virtual: false
            },
            {
              name: 'record_type',
              display_name: model.human_attribute_name(:record_type),
              column_type: 'string',
              access_type: 'read_write',
              default_value: nil,
              validators: [],
              format: {},
              is_array: false,
              reference: nil,
              virtual: false
            },
            {
              name: 'record_id',
              display_name: model.human_attribute_name(:record),
              column_type: 'integer',
              access_type: 'read_write',
              default_value: nil,
              validators: [],
              format: {},
              is_array: false,
              reference: {
                name: 'record',
                display_name: model.human_attribute_name(:record),
                model_name: nil,
                reference_type: 'belongs_to',
                foreign_key: 'record_id',
                polymorphic: true
              },
              virtual: false
            },
            {
              name: 'file',
              display_name: model.human_attribute_name(:file),
              column_type: 'file',
              access_type: 'write_only',
              default_value: nil,
              validators: [],
              format: {},
              is_array: false,
              reference: nil,
              virtual: false
            },
            {
              name: 'created_at',
              display_name: model.human_attribute_name(:created_at),
              column_type: 'datetime',
              access_type: 'read_only',
              default_value: nil,
              validators: [],
              format: {},
              is_array: false,
              reference: nil,
              virtual: false
            }
          ],
          associations: [],
          scopes: [],
          preferences: {},
          actions: Motor::BuildSchema::Defaults.actions.reject { |e| e[:name] == 'edit' },
          tabs: Motor::BuildSchema::Defaults.tabs,
          visible: false
        }.with_indifferent_access
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
