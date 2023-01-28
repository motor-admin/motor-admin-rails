# frozen_string_literal: true

module Motor
  module ApiQuery
    module Search
      STRING_COLUMN_TYPES = %i[text string citext].freeze
      NUMBER_COLUMN_TYPES = %i[integer float].freeze

      module_function

      def call(rel, keyword)
        return rel if keyword.blank?

        filters = fetch_filters(rel, keyword)

        arel_where = build_arel_or_query(filters)

        rel.where(arel_where)
      end

      def fetch_filters(rel, keyword)
        klass = rel.klass

        selected_columns = find_searchable_columns(klass)

        build_arel_filters(klass, selected_columns, keyword)
      end

      def build_arel_filters(model, column_names, keyword)
        arel_table = model.arel_table

        column_names.map do |name|
          column_type = model.columns_hash[name]&.type

          next unless column_type

          if STRING_COLUMN_TYPES.include?(column_type)
            arel_table[name].matches("%#{keyword}%")
          elsif NUMBER_COLUMN_TYPES.include?(column_type)
            arel_table[name].eq(keyword.to_f) if keyword.match?(/\A\d/)
          else
            arel_table[name].eq(keyword)
          end
        end.compact
      end

      def build_arel_or_query(filter_array)
        filter_array.reduce(nil) do |acc, filter|
          next acc = filter unless acc

          acc.or(filter)
        end
      end

      def find_searchable_columns(model)
        model.try(:motor_searchable_columns) || Motor::BuildSchema::FindSearchableColumns.call(model)
      end
    end
  end
end
