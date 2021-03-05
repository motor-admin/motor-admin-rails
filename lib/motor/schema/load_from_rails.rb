module Motor
  module Schema
    module LoadFromRails
      module_function

      def call
        models.map do |model|
          build_resource_shema(model)
        end
      end

      def models
        Rails.application.eager_load!

        models = load_descendants(ActiveRecord::Base).uniq
        models = models.reject(&:abstract_class)

        models -= Motor::ApplicationRecord.descendants
        models -= [ActiveRecord::SchemaMigration] if defined?(ActiveRecord::SchemaMigration)

        models
      end

      def load_descendants(model)
        model.descendants + model.descendants.flat_map do |klass|
          load_descendants(klass)
        end
      end

      def build_resource_shema(model)
        {
          name: model.name,
          slug: model.name.underscore.pluralize,
          table_name: model.table_name,
          display_name: model.name.titleize.pluralize,
          columns: fetch_columns(model)
        }
      end

      def fetch_columns(model)
        model.columns.map do |column|
          {
            name: column.name,
            column_type: column.type.to_s,
            validators: fetch_validators(model, column.name)
          }
        end
      end

      def fetch_validators(model, column_name)
        model.validators_on(column_name).filter_map do |validator|
          case validator
          when ActiveModel::Validations::InclusionValidator
            { includes: validator.send(:delimiter) }
          when ActiveRecord::Validations::PresenceValidator
            { required: true }
          when ActiveModel::Validations::FormatValidator
            { format: validator.options[:with] }
          when ActiveRecord::Validations::UniquenessValidator
            next
          else
            raise ArgumentError, 'Unknown validator class'
          end
        end
      end
    end
  end
end
