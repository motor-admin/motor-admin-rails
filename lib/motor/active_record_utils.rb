# frozen_string_literal: true

module Motor
  module ActiveRecordUtils
    module_function

    def reset_id_sequence!(model)
      case ActiveRecord::Base.connection.class.name
      when 'ActiveRecord::ConnectionAdapters::PostgreSQLAdapter'
        ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
      else
        ActiveRecord::Base.connection.reset_sequence!(model.table_name, 'id')
      end
    end
  end
end

require_relative './active_record_utils/types'
require_relative './active_record_utils/fetch_methods'
require_relative './active_record_utils/defined_scopes_extension'
require_relative './active_record_utils/active_storage_links_extension'
require_relative './active_record_utils/active_storage_blob_patch'
