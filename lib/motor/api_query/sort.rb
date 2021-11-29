# frozen_string_literal: true

module Motor
  module ApiQuery
    module Sort
      FIELD_PARSE_REGEXP = /\A(-)?(.*)\z/.freeze

      module_function

      def call(rel, param)
        return rel if param.blank?

        arel_order = build_arel_order(rel.klass, param)
        join_params = build_join_params(rel.klass, param)

        rel = rel.left_joins(join_params) if join_params.present?

        rel.reorder(arel_order)
      end

      def build_join_params(_model, param)
        param.split(',').each_with_object({}) do |field, result|
          key = field[FIELD_PARSE_REGEXP, 2]
          *path, _ = key.split('.')

          path.reduce(result) do |acc, fragment|
            hash = {}

            acc[fragment] = hash

            hash
          end
        end
      end

      def build_arel_order(model, param)
        param.split(',').map do |field|
          direction, key = field.match(FIELD_PARSE_REGEXP).captures
          *path, field = key.split('.')

          reflection_model =
            path.reduce(model) do |acc, fragment|
              acc.reflections[fragment].klass
            end

          arel_column = reflection_model.arel_table[field]

          arel_direction = direction.present? ? arel_column.desc : arel_column.asc

          maybe_add_null_last(model, arel_direction)
        end
      end

      def maybe_add_null_last(model, arel_direction)
        if arel_direction.respond_to?(:nulls_last) &&
           model.connection.class.name == 'ActiveRecord::ConnectionAdapters::PostgreSQLAdapter'
          arel_direction.nulls_last
        else
          arel_direction
        end
      end
    end
  end
end
