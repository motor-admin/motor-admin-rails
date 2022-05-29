# frozen_string_literal: true

module Motor
  module BuildSchema
    module FindSearchableColumns
      SELECT_COLUMNS_AMOUNT = 2
      COLUMN_TYPES = BuildSchema::SEARCHABLE_COLUMN_TYPES

      module_function

      def call(model)
        columns = find_searchable_columns(model)

        selected_columns =
          columns.grep(BuildSchema::FindDisplayColumn::DISPLAY_NAME_REGEXP).presence

        selected_columns ||= columns.first(SELECT_COLUMNS_AMOUNT)

        ([model.primary_key] + selected_columns).compact.sort
      end

      def find_searchable_columns(model)
        model.columns.map do |column|
          next unless column.type.in?(COLUMN_TYPES)
          next if column.try(:array?)
          next if model.validators_on(column.name).any?(ActiveModel::Validations::InclusionValidator)

          column.name
        end.compact
      end
    end
  end
end
