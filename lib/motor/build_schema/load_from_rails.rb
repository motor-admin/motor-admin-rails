# frozen_string_literal: true

module Motor
  module BuildSchema
    module LoadFromRails
      module ColumnAccessTypes
        ALL = [
          READ_ONLY = 'read_only',
          WRITE_ONLY = 'write_only',
          READ_WRITE = 'read_write',
          HIDDEN = 'hidden'
        ].freeze
      end

      module_function

      def call
        models.map do |model|
          build_model_schema(model)
        end
      end

      def models
        Rails.application.eager_load!

        models = load_descendants(ActiveRecord::Base).uniq
        models = models.reject(&:abstract_class)

        models -= Motor::ApplicationRecord.descendants
        models -= [ActiveRecord::SchemaMigration] if defined?(ActiveRecord::SchemaMigration)
        models -= [ActiveStorage::Blob, ActiveStorage::VariantRecord] if defined?(ActiveStorage::Blob)

        models
      end

      def load_descendants(model)
        model.descendants + model.descendants.flat_map do |klass|
          load_descendants(klass)
        end
      end

      def build_model_schema(model)
        {
          name: model.name.underscore,
          slug: Utils.slugify(model),
          table_name: model.table_name,
          primary_key: model.primary_key,
          display_name: model.name.titleize.pluralize,
          display_column: FindDisplayColumn.call(model),
          columns: fetch_columns(model),
          associations: fetch_associations(model),
          default_values: model.new.attributes.select { |_, v| v.present? }
        }
      end

      def fetch_columns(model)
        model.columns.map do |column|
          {
            name: column.name,
            display_name: column.name.humanize,
            column_type: column.type.to_s,
            access_type: ColumnAccessTypes::READ_WRITE,
            validators: fetch_validators(model, column.name)
          }
        end
      end

      def fetch_associations(model)
        model.reflections.map do |name, ref|
          next if ref.polymorphic? && !ref.belongs_to?

          begin
            ref.klass
          rescue StandardError
            next
          end

          next if defined?(ActiveStorage::Blob) && ref.klass == ActiveStorage::Blob

          {
            name: name,
            display_name: name.humanize,
            slug: name.underscore,
            model_name: ref.klass.name.underscore,
            model_slug: Utils.slugify(ref.klass),
            association_type: fetch_association_type(ref),
            foreign_key: ref.foreign_key,
            polymorphic: ref.polymorphic?
          }
        end.compact
      end

      def fetch_association_type(association)
        case association.association_class.to_s
        when 'ActiveRecord::Associations::HasManyAssociation',
             'ActiveRecord::Associations::HasManyThroughAssociation'
          'has_many'
        when 'ActiveRecord::Associations::HasOneAssociation',
             'ActiveRecord::Associations::HasOneThroughAssociation'
          'has_one'
        when 'ActiveRecord::Associations::BelongsToAssociation'
          'belongs_to'
        else
          raise ArgumentError, 'Unknown association type'
        end
      end

      def fetch_validators(model, column_name)
        model.validators_on(column_name).map do |validator|
          case validator
          when ActiveModel::Validations::InclusionValidator
            { includes: validator.send(:delimiter) }
          when ActiveRecord::Validations::PresenceValidator
            { required: true }
          when ActiveModel::Validations::FormatValidator
            { format: JsRegex.new(validator.options[:with]).to_h.slice(:source, :options) }
          when ActiveRecord::Validations::LengthValidator
            { length: validator.options }
          when ActiveModel::Validations::NumericalityValidator
            { numeric: validator.options }
          else
            next
          end
        end.compact
      end
    end
  end
end
