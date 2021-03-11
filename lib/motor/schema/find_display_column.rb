# frozen_string_literal: true

module Motor
  module Schema
    module FindDisplayColumn
      DISPLAY_NAMES = %w[
        name
        full_name
        last_name
        first_name
        phone
        email
        domain
        phone
        title
        url
      ].freeze

      DISPLAY_NAME_REGEXP = Regexp.new(Regexp.union(DISPLAY_NAMES), Regexp::IGNORECASE)

      module_function

      def call(model)
        column_names = fetch_column_names(model)

        select_column_name(column_names)
      end

      def select_column_name(column_names)
        name   = column_names.find { |column_name| column_name.in?(DISPLAY_NAMES) }
        name ||= column_names.find { |column_name| column_name.match?(DISPLAY_NAME_REGEXP) }

        name
      end

      def fetch_column_names(model)
        model.columns.map do |column|
          next unless column.type.in?(Schema::SEARCHABLE_COLUMN_TYPES)

          column.name
        end.compact
      end
    end
  end
end
