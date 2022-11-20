# frozen_string_literal: true

module Motor
  module Resources
    RESOURCE_ATTRS = %w[display_name display_column icon custom_sql visible display_primary_key
                        searchable_columns preferences].freeze
    COLUMN_ATTRS = %w[name display_name column_type access_type default_value reference virtual format
                      validators description].freeze
    ASSOCIATION_ATTRS = %w[name display_name model_name icon visible foreign_key primary_key options virtual
                           polymorphic slug].freeze
    SCOPE_ATTRS = %w[name display_name scope_type preferences visible].freeze
    ACTION_ATTRS = %w[name display_name action_type preferences apply_on visible].freeze
    TAB_ATTRS = %w[name display_name tab_type preferences visible].freeze
  end
end

require_relative './resources/fetch_configured_model'
require_relative './resources/persist_configs'
require_relative './resources/custom_sql_columns_cache'
