# frozen_string_literal: true

module Motor
  module Queries
    module RunQuery
      DEFAULT_LIMIT = 1_000_000
      INTERPOLATION_REGEXP = /{{(\w+)}}/.freeze

      QueryResult = Struct.new(:data, :columns, keyword_init: true)

      WITH_STATEMENT_TEMPLATE = <<~SQL.squish
        WITH __query__ AS (%<sql_body>s)
        SELECT * FROM __query__ LIMIT %<limit>s;
      SQL

      module_function

      def call(query, limit: DEFAULT_LIMIT, variables_hash: {})
        result = execute_query(query, limit, variables_hash)

        QueryResult.new(data: result.rows, columns: build_columns_hash(result))
      end

      def execute_query(query, limit, variables_hash)
        statement = prepare_sql_statement(query, limit, variables_hash)

        case ActiveRecord::Base.connection
        when ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
          PostgresqlExecQuery.call(ActiveRecord::Base.connection, statement)
        else
          ActiveRecord::Base.connection.exec_query(*statement)
        end
      end

      # @params result [ActiveRecord::Result]
      # @return [Hash]
      def build_columns_hash(result)
        result.columns.map do |column_name|
          column_type_class = result.column_types[column_name].class

          {
            name: column_name,
            display_name: column_name.humanize,
            column_type: ActiveRecordUtils::Types.find_name_for_class(column_type_class)
          }
        end
      end

      def prepare_sql_statement(query, limit, variables_hash)
        variables = query.preferences[:variables].pluck(:name)

        sql =
          query.sql_body.gsub(INTERPOLATION_REGEXP) do
            index = variables.index(Regexp.last_match[1])

            "$#{index}"
          end

        [
          format(WITH_STATEMENT_TEMPLATE, sql_body: sql.squish.gsub(/;\z/, ''), limit: limit),
          'SQL',
          variables_hash.with_indifferent_access.values_at(*variables)
        ]
      end
    end
  end
end
