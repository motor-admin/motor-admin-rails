# frozen_string_literal: true

require_relative './schema/load_from_rails'
require_relative './schema/find_display_column'
require_relative './schema/utils'

module Motor
  module Schema
    SEARCHABLE_COLUMN_TYPES = %i[citext text string bitstring].freeze

    module_function

    def load
      LoadFromRails.call
    end
  end
end
