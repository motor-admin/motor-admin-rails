# frozen_string_literal: true

module Motor
  module ApiQuery
    module Search
      SELECT_COLUMNS_AMOUNT = 2
      COLUMN_TYPES = BuildSchema::SEARCHABLE_COLUMN_TYPES
      ID_REGEXP = /\A\d+\z/.freeze

      module_function

      def call(rel, keyword)
        return rel if keyword.blank?

        filters = fetch_filters(rel, keyword)

        arel_where = build_arel_or_query(filters)

        rel.where(arel_where)
      end

      def fetch_filters(rel, keyword)
        arel_filters = []

        klass = rel.klass
        arel_table = klass.arel_table

        arel_filters << arel_table[klass.primary_key].eq(keyword) if keyword.match?(ID_REGEXP)

        string_column_names = find_searchable_columns(klass)
        selected_columns = select_columns(string_column_names)

        selected_columns.each { |name| arel_filters << arel_table[name].matches("%#{keyword}%") }

        arel_filters
      end

      def build_arel_or_query(filter_array)
        filter_array.reduce(nil) do |acc, filter|
          next acc = filter unless acc

          acc.or(filter)
        end
      end

      def select_columns(columns)
        selected_columns =
          columns.grep(BuildSchema::FindDisplayColumn::DISPLAY_NAME_REGEXP).presence

        selected_columns ||= columns.first(SELECT_COLUMNS_AMOUNT)

        selected_columns
      end

      def find_searchable_columns(model)
        model.columns.map do |column|
          next unless column.type.in?(COLUMN_TYPES)
          next if column.respond_to?(:array?) && column.array?
          next if model.validators_on(column.name).any?(ActiveModel::Validations::InclusionValidator)

          column.name
        end.compact
      end
    end
  end
end
