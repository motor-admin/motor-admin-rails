# frozen_string_literal: true

require_relative './build_schema/load_from_rails'
require_relative './build_schema/find_display_column'
require_relative './build_schema/utils'

module Motor
  module BuildSchema
    SEARCHABLE_COLUMN_TYPES = %i[citext text string bitstring].freeze

    module_function

    def call
      LoadFromRails.call
    end
  end
end
