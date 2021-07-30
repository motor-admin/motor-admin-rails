# frozen_string_literal: true

module Motor
  module Queries
    module RunQuery
      DEFAULT_LIMIT = 100_000

      QueryResult = Struct.new(:data, :columns, :error, keyword_init: true)

      CTE_NAME = '__query__'

      WITH_STATEMENT_START = "WITH #{CTE_NAME} AS ("

      WITH_STATEMENT_TEMPLATE = <<~SQL
        #{WITH_STATEMENT_START}%<sql_body>s
        )
      SQL

      STATEMENT_VARIABLE_REGEXP = /\$\d+/.freeze
      PG_ERROR_REGEXP = /\APG.+ERROR:/.freeze

      RESERVED_VARIABLES = %w[current_user_id current_user_email].freeze

      module_function

      # @param query [Motor::Query]
      # @param variables_hash [Hash]
      # @param limit [Integer]
      # @param filters [Hash]
      # @return [Motor::Queries::RunQuery::QueryResult]
      def call!(query, variables_hash: nil, limit: nil, filters: nil)
        variables_hash ||= {}
        limit ||= DEFAULT_LIMIT
        filters ||= {}

        result = execute_query(query, limit, variables_hash, filters)

        QueryResult.new(data: result.rows, columns: build_columns_hash(result))
      end

      # @param query [Motor::Query]
      # @param variables_hash [Hash]
      # @param limit [Integer]
      # @return [Motor::Queries::RunQuery::QueryResult]
      def call(query, variables_hash: nil, limit: nil, filters: nil)
        call!(query, variables_hash: variables_hash, limit: limit, filters: filters)
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
      # @param filters [Hash]
      # @return [ActiveRecord::Result]
      def execute_query(query, limit, variables_hash, filters)
        result = nil
        statement = prepare_sql_statement(query, limit, variables_hash, filters)

        connection_class.transaction do
          result =
            case connection_class.connection.class.name
            when 'ActiveRecord::ConnectionAdapters::PostgreSQLAdapter'
              PostgresqlExecQuery.call(connection_class.connection, statement)
            else
              statement = normalize_statement_for_sql(statement)

              connection_class.connection.exec_query(*statement)
            end

          raise ActiveRecord::Rollback
        end

        result
      end

      # @param result [ActiveRecord::Result]
      # @return [Hash]
      def build_columns_hash(result)
        result.columns.map do |column_name|
          column_type = result.column_types[column_name]

          {
            name: column_name,
            display_name: column_name.humanize,
            column_type: ActiveRecordUtils::Types.find_name_for_type(column_type),
            is_array: column_type.class.to_s == 'ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array'
          }
        end
      end

      # @param query [Motor::Query]
      # @param limit [Integer]
      # @param variables_hash [Hash]
      # @param filters [Hash]
      # @return [Array]
      def prepare_sql_statement(query, limit, variables_hash, filters)
        variables = merge_variable_default_values(query.preferences.fetch(:variables, []), variables_hash)

        sql, query_variables = RenderSqlTemplate.call(query.sql_body, variables)
        cte_sql = format(WITH_STATEMENT_TEMPLATE, sql_body: sql.strip.delete_suffix(';'))
        cte_select_sql = build_cte_select_sql(limit, filters)

        attributes = build_statement_attributes(query_variables)

        [[cte_sql, cte_select_sql].join, 'SQL', attributes]
      end

      # @param limit [Number]
      # @param filters [Hash]
      # @return [String]
      def build_cte_select_sql(limit, filters)
        table = Arel::Table.new(CTE_NAME)

        arel_filters = build_filters_arel(filters)

        expresion = table.project(table[Arel.star])
        expresion = expresion.where(arel_filters) if arel_filters.present?

        expresion.take(limit.to_i).to_sql
      end

      # @param filters [Hash]
      # @return [Arel::Nodes, nil]
      def build_filters_arel(filters)
        return nil if filters.blank?

        table = Arel::Table.new(CTE_NAME)

        arel_filters = filters.map { |key, value| table[key].in(value) }

        arel_filters[1..].reduce(arel_filters.first) { |acc, arel| acc.and(arel) }
      end

      # @param variables [Array<(String, Object)>]
      # @return [Array<ActiveRecord::Relation::QueryAttribute>]
      def build_statement_attributes(variables)
        variables.map do |variable_name, value|
          [value].flatten.map do |val|
            ActiveRecord::Relation::QueryAttribute.new(
              variable_name,
              val,
              ActiveRecord::Type::Value.new
            )
          end
        end.flatten
      end

      # @param array [Array]
      # @return [Array]
      def normalize_statement_for_sql(statement)
        sql, _, attributes = statement

        sql = ActiveRecord::Base.sanitize_sql([sql.gsub(STATEMENT_VARIABLE_REGEXP, '?'), attributes.map(&:value)])

        [sql, 'SQL', attributes]
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

      def connection_class
        defined?(ResourceRecord) ? ResourceRecord : ActiveRecord::Base
      end
    end
  end
end
