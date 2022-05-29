# frozen_string_literal: true

module Motor
  module BuildSchema
    module FindDisplayColumn
      DISPLAY_NAMES = Set.new(
        %w[
          name
          full_name
          fullname
          last_name
          lastname
          first_name
          firstname
          fname
          lname
          sname
          company
          domain
          website
          title
          phone
          phone_number
          email
          phone
          filename
          file_name
          url
          make
          brand
          manufacturer
          model
          address
          code
        ]
      ).freeze

      DISPLAY_NAME_REGEXP = Regexp.new(Regexp.union(DISPLAY_NAMES.to_a).source, Regexp::IGNORECASE)

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
          next unless column.type.in?(BuildSchema::SEARCHABLE_COLUMN_TYPES)
          next if column.try(:array?)

          column.name
        end.compact
      end
    end
  end
end
