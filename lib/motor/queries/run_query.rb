# frozen_string_literal: true

module Motor
  module Queries
    module RunQuery
      DEFAULT_LIMIT = 1_000_000

      QueryResult = Struct.new(:data, :columns, keyword_init: true)

      WITH_STATEMENT_TEMPLATE = <<~SQL
        WITH __query__ AS (%<sql_body>s) SELECT * FROM __query__ LIMIT %<limit>s;
      SQL

      module_function

      def call(query, variables_hash: nil, limit: DEFAULT_LIMIT)
        variables_hash ||= {}

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

      # @param result [ActiveRecord::Result]
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
        variables = merge_variable_default_values(query.preferences.fetch(:variables, []), variables_hash)

        sql, query_variables = RenderSqlTemplate.call(query.sql_body, variables)

        attributes = build_statement_attributes(query_variables)

        [format(WITH_STATEMENT_TEMPLATE, sql_body: sql.strip.gsub(/;\z/, ''), limit: limit), 'SQL', attributes]
      end

      def build_statement_attributes(variables)
        variables.map do |variable_name, value|
          ActiveRecord::Relation::QueryAttribute.new(
            variable_name,
            value,
            ActiveRecord::Type::Value.new
          )
        end
      end

      def merge_variable_default_values(variable_configs, variables_hash)
        variable_configs.each_with_object({}) do |variable, acc|
          acc[variable[:name]] = variables_hash[variable[:name]] || variable[:default_value]
        end
      end
    end
  end
end
