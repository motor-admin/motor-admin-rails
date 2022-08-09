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

    def generate_csv_for_relation(relation, reset_limit: false)
      relation = relation.limit(nil).offset(nil) if reset_limit

      result = load_query_for_csv(relation)

      CSV.generate do |csv|
        csv << result.columns

        result.rows.each { |row| csv << row }
      end
    end

    def load_query_for_csv(relation)
      model_name = relation.klass.model_name.human(count: :many, default: relation.klass.name.titleize.pluralize)

      query = Motor::Query.find_by(name: "Export #{model_name}")

      relation.klass.connection.exec_query(query&.sql_body || relation.to_sql)
    end
  end
end

require_relative './active_record_utils/types'
require_relative './active_record_utils/fetch_methods'
require_relative './active_record_utils/defined_scopes_extension'
require_relative './active_record_utils/active_storage_links_extension'
require_relative './active_record_utils/active_storage_blob_patch'
require_relative './active_record_utils/active_record_filter'
require_relative './active_record_utils/active_record_connection_column_patch'
require_relative './active_record_utils/action_text_attribute_patch'
