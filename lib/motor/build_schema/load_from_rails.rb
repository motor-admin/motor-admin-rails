# frozen_string_literal: true

module Motor
  module BuildSchema
    module LoadFromRails
      MUTEX = Mutex.new
      UNIFIED_TYPES = ActiveRecordUtils::Types::UNIFIED_TYPES

      I18N_SCOPES_KEY = 'activerecord.scopes'

      ACTION_TEXT_REFLECTION_PREFIX = 'rich_text_'
      ACTION_TEXT_COLUMN_SUFFIX = '_body'
      ACTION_TEXT_SCOPE_PREFIX = 'with_rich_text_'
      ACTIVE_STORAGE_SCOPE_PREFIX = 'with_attached_'

      module_function

      def call
        models.map do |model|
          Object.const_get(model.name)

          next unless ActiveRecord::Base.connection.table_exists?(model.table_name)

          schema = build_model_schema(model)

          if model.respond_to?(:devise_modules)
            Motor::BuildSchema::AdjustDeviseModelSchema.call(schema, model.devise_modules)
          end

          schema
        rescue StandardError, NotImplementedError => e
          Rails.logger.error(e)

          next
        end.compact
      end

      def models
        eager_load_models!

        models = ActiveRecord::Base.descendants.reject(&:abstract_class)

        models -= Motor::ApplicationRecord.descendants
        models -= [Motor::Audit]
        models -= [ActiveRecord::SchemaMigration] if defined?(ActiveRecord::SchemaMigration)
        models -= [ActiveRecord::InternalMetadata] if defined?(ActiveRecord::InternalMetadata)
        models -= [ActiveStorage::Blob] if defined?(ActiveStorage::Blob)
        models -= [ActionText::RichText] if defined?(ActionText::RichText)
        models -= [ActiveStorage::VariantRecord] if defined?(ActiveStorage::VariantRecord)

        models
      end

      def build_model_schema(model)
        model_name = model.name

        return Motor::BuildSchema::ActiveStorageAttachmentSchema.call if model_name == 'ActiveStorage::Attachment'

        {
          name: model_name.underscore,
          slug: Utils.slugify(model),
          table_name: model.table_name,
          class_name: model.name,
          primary_key: model.primary_key,
          display_name: model.model_name.human(count: :many, default: model_name.titleize.pluralize),
          display_column: FindDisplayColumn.call(model),
          columns: fetch_columns(model),
          associations: fetch_associations(model),
          icon: Motor::FindIcon.call(model_name),
          scopes: fetch_scopes(model),
          actions: BuildSchema::Defaults.actions,
          tabs: BuildSchema::Defaults.tabs,
          visible: true
        }.with_indifferent_access
      end

      def fetch_scopes(model)
        model.defined_scopes.map do |scope_name|
          scope_name = scope_name.to_s

          next if scope_name.starts_with?(ACTIVE_STORAGE_SCOPE_PREFIX)
          next if scope_name.starts_with?(ACTION_TEXT_SCOPE_PREFIX)

          {
            name: scope_name,
            display_name: I18n.t(scope_name,
                                 scope: [I18N_SCOPES_KEY, model.name.underscore].join('.'),
                                 default: scope_name.humanize),
            scope_type: DEFAULT_SCOPE_TYPE,
            visible: true,
            preferences: {}
          }
        end.compact
      end

      def fetch_columns(model)
        default_attrs = model.new.attributes

        reference_columns = fetch_reference_columns(model)

        table_columns =
          model.columns.map do |column|
            next if reference_columns.find { |c| c[:name] == column.name }

            build_table_column(column, model, default_attrs)
          end.compact

        reference_columns + table_columns
      end

      def build_table_column(column, model, default_attrs)
        is_enum = model.defined_enums[column.name]

        {
          name: column.name,
          display_name: Utils.humanize_column_name(model.human_attribute_name(column.name)),
          column_type: is_enum ? 'string' : UNIFIED_TYPES[column.type.to_s] || column.type.to_s,
          is_array: column.array?,
          access_type: COLUMN_NAME_ACCESS_TYPES.fetch(column.name, ColumnAccessTypes::READ_WRITE),
          default_value: default_attrs[column.name],
          validators: fetch_validators(model, column.name),
          reference: nil,
          format: {},
          virtual: false
        }
      end

      def fetch_reference_columns(model)
        default_attrs = model.new.attributes

        model.reflections.map do |name, ref|
          next if !ref.has_one? && !ref.belongs_to?

          unless ref.polymorphic?
            begin
              next if ref.klass.name == 'ActiveStorage::Blob'
            rescue StandardError => e
              Rails.logger.error(e)

              next
            end
          end

          build_reflection_column(name, model, ref, default_attrs)
        end.compact
      end

      def build_reflection_column(name, model, ref, default_attrs)
        return build_action_text_column(name, model, ref) if ref.klass.name == 'ActionText::RichText'

        column_name = ref.belongs_to? ? ref.foreign_key.to_s : name
        is_attachment = !ref.polymorphic? && ref.klass.name == 'ActiveStorage::Attachment'
        access_type = ref.belongs_to? || is_attachment ? ColumnAccessTypes::READ_WRITE : ColumnAccessTypes::READ_ONLY

        {
          name: column_name,
          display_name: model.human_attribute_name(name),
          column_type: is_attachment ? 'file' : 'integer',
          access_type: access_type,
          default_value: default_attrs[column_name],
          validators: fetch_validators(model, column_name, ref),
          format: {},
          reference: build_reference(model, name, ref),
          virtual: false
        }
      end

      def build_action_text_column(name, model, ref)
        name = name.delete_prefix(ACTION_TEXT_REFLECTION_PREFIX)

        {
          name: name + ACTION_TEXT_COLUMN_SUFFIX,
          display_name: model.human_attribute_name(name),
          column_type: 'richtext',
          access_type: BuildSchema::ColumnAccessTypes::READ_WRITE,
          default_value: '',
          validators: fetch_validators(model, name, ref),
          format: {},
          reference: nil,
          virtual: true
        }
      end

      def build_reference(model, name, reflection)
        {
          name: name,
          display_name: model.human_attribute_name(name),
          model_name: reflection.polymorphic? ? nil : reflection.klass.name.underscore,
          reference_type: reflection.belongs_to? ? 'belongs_to' : 'has_one',
          foreign_key: reflection.foreign_key,
          association_primary_key: reflection.polymorphic? ? 'id' : reflection.association_primary_key,
          polymorphic: reflection.polymorphic?
        }
      end

      def fetch_associations(model)
        model.reflections.map do |name, ref|
          next if ref.has_one? || ref.belongs_to?
          next unless valid_reflection?(ref)

          model_class = ref.klass

          next if model_class.name == 'ActiveStorage::Blob'

          {
            name: name,
            display_name: model.human_attribute_name(name),
            slug: name.underscore,
            model_name: model_class.name.underscore,
            foreign_key: ref.foreign_key,
            polymorphic: ref.options[:as].present?,
            icon: Motor::FindIcon.call(name),
            visible: true
          }
        end.compact
      end

      def fetch_validators(model, column_name, reflection = nil)
        validators =
          if reflection&.belongs_to? && !reflection.options[:optional]
            [{ required: true }]
          else
            []
          end

        enum = model.defined_enums[column_name]

        validators += [{ includes: enum.keys }] if enum

        validators += model.validators_on(column_name).map do |validator|
          build_validator_hash(validator)
        end.compact

        validators.uniq
      end

      def build_validator_hash(validator)
        options = validator.options.reject { |_, v| v.is_a?(Proc) }

        case validator
        when ActiveModel::Validations::InclusionValidator
          { includes: validator.send(:delimiter) }
        when ActiveRecord::Validations::PresenceValidator
          { required: true }
        when ActiveModel::Validations::FormatValidator
          { format: JsRegex.new(options[:with]).to_h.slice(:source, :options) }
        when ActiveRecord::Validations::LengthValidator
          { length: options }
        when ActiveModel::Validations::NumericalityValidator
          { numeric: options }
        end
      end

      def valid_reflection?(reflection)
        reflection.klass
        reflection.foreign_key

        true
      rescue StandardError => e
        Rails.logger.error(e)

        false
      end

      def eager_load_models!
        MUTEX.synchronize do
          if Rails::VERSION::MAJOR > 5 && defined?(Zeitwerk::Loader)
            Zeitwerk::Loader.eager_load_all
          else
            Rails.application.eager_load!
          end

          ActiveRecord::Base.descendants.each do |model|
            model.reflections.each do |_, ref|
              ref.klass
            rescue StandardError
              next
            end
          end
        end
      end
    end
  end
end
