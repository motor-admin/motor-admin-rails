# frozen_string_literal: true

module Motor
  module Queries
    module RunQuery
      DEFAULT_LIMIT = 100_000

      QueryResult = Struct.new(:data, :columns, :error, keyword_init: true)

      WITH_STATEMENT_START = 'WITH __query__ AS ('

      WITH_STATEMENT_TEMPLATE = <<~SQL
        #{WITH_STATEMENT_START}%<sql_body>s
        ) SELECT * FROM __query__ LIMIT %<limit>s;
      SQL

      PG_ERROR_REGEXP = /\APG.+ERROR:/.freeze

      RESERVED_VARIABLES = %w[current_user_id current_user_email].freeze

      module_function

      # @param query [Motor::Query]
      # @param variables_hash [Hash]
      # @param limit [Integer]
      # @return [Motor::Queries::RunQuery::QueryResult]
      def call!(query, variables_hash: nil, limit: DEFAULT_LIMIT)
        variables_hash ||= {}

        result = execute_query(query, limit, variables_hash)

        QueryResult.new(data: result.rows, columns: build_columns_hash(result))
      end

      # @param query [Motor::Query]
      # @param variables_hash [Hash]
      # @param limit [Integer]
      # @return [Motor::Queries::RunQuery::QueryResult]
      def call(query, variables_hash: nil, limit: DEFAULT_LIMIT)
        call!(query, variables_hash: variables_hash, limit: limit)
      rescue ActiveRecord::StatementInvalid => e
        QueryResult.new(error: build_error_message(e))
      end

      # @param exception [ActiveRecord::StatementInvalid]
      # @return [String]
      def build_error_message(exception)
        exception.message.sub(WITH_STATEMENT_START, '').sub(PG_ERROR_REGEXP, '').strip.upcase_first
      end

      # @param query [Motor::Query]
      # @param limit [Integer]
      # @param variables_hash [Hash]
      # @return [ActiveRecord::Result]
      def execute_query(query, limit, variables_hash)
        result = nil
        statement = prepare_sql_statement(query, limit, variables_hash)

        ActiveRecord::Base.transaction do
          result =
            case ActiveRecord::Base.connection.class.name
            when 'ActiveRecord::ConnectionAdapters::PostgreSQLAdapter'
              PostgresqlExecQuery.call(ActiveRecord::Base.connection, statement)
            else
              ActiveRecord::Base.connection.exec_query(*statement)
            end

          raise ActiveRecord::Rollback
        end

        result
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

      # @param query [Motor::Query]
      # @param limit [Integer]
      # @param variables_hash [Hash]
      # @return [Array]
      def prepare_sql_statement(query, limit, variables_hash)
        variables = merge_variable_default_values(query.preferences.fetch(:variables, []), variables_hash)

        sql, query_variables = RenderSqlTemplate.call(query.sql_body, variables)

        attributes = build_statement_attributes(query_variables)

        [format(WITH_STATEMENT_TEMPLATE, sql_body: sql.strip.delete_suffix(';'), limit: limit), 'SQL', attributes]
      end

      # @param variables [Array<(String, Object)>]
      # @return [Array<ActiveRecord::Relation::QueryAttribute>]
      def build_statement_attributes(variables)
        variables.map do |variable_name, value|
          ActiveRecord::Relation::QueryAttribute.new(
            variable_name,
            value,
            ActiveRecord::Type::Value.new
          )
        end
      end

      # @param variable_configs [Array<Hash>]
      # @param variables_hash [Hash]
      # @return [Hash]
      def merge_variable_default_values(variable_configs, variables_hash)
        variable_configs.each_with_object(variables_hash.slice(*RESERVED_VARIABLES)) do |variable, acc|
          next if RESERVED_VARIABLES.include?(variable[:name])

          acc[variable[:name]] ||= variables_hash[variable[:name]] || variable[:default_value]
        end
      end
    end
  end
end
