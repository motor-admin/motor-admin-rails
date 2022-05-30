# frozen_string_literal: true

module Motor
  module Queries
    module RunQuery
      DEFAULT_LIMIT = 100_000

      QueryResult = Struct.new(:data, :columns, :error, keyword_init: true)

      SUBQUERY_NAME = '__query__'

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
        exception.message.sub(PG_ERROR_REGEXP, '').strip.upcase_first
      end

      # @param query [Motor::Query]
      # @param limit [Integer]
      # @param variables_hash [Hash]
      # @param filters [Hash]
      # @return [ActiveRecord::Result]
      def execute_query(query, limit, variables_hash, filters)
        result = nil
        statement = prepare_sql_statement(connection_class, query, limit, variables_hash, filters)

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
        result.columns.map.with_index do |column_name, index|
          column_type_class = result.column_types[column_name]

          column_type = ActiveRecordUtils::Types.find_name_for_type(column_type_class) if column_type_class

          column_type ||=
            begin
              not_nil_value = result.rows.reduce(nil) do |acc, row|
                column = row[index]

                break column unless column.nil?

                acc
              end

              fetch_column_type_from_value(not_nil_value)
            end

          {
            name: column_name,
            display_name: column_name.humanize,
            column_type: column_type,
            is_array: column_type.class.to_s == 'ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array'
          }
        end
      end

      # @param value [Object]
      # @return [String]
      def fetch_column_type_from_value(value)
        case value
        when Integer
          'integer'
        when Float
          'float'
        when Time
          'datetime'
        when Date
          'date'
        when TrueClass, FalseClass
          'boolean'
        else
          'string'
        end
      end

      # @param connection_class [Class]
      # @param query [Motor::Query]
      # @param limit [Integer]
      # @param variables_hash [Hash]
      # @param filters [Hash]
      # @return [Array]
      def prepare_sql_statement(connection_class, query, limit, variables_hash, filters)
        variables = merge_variable_default_values(query.preferences.fetch(:variables, []), variables_hash)

        sql, query_variables = RenderSqlTemplate.call(query.sql_body, variables)
        select_sql = build_select_sql(connection_class, sql, limit, filters)

        attributes = build_statement_attributes(query_variables)

        [select_sql, 'SQL', attributes]
      end

      # @param connection_class [Class]
      # @param sql [String]
      # @param limit [Number]
      # @param filters [Hash]
      # @return [String]
      def build_select_sql(connection_class, sql, limit, filters)
        sql = sql.strip.delete_suffix(';').gsub(/\A\)+/, '').gsub(/\z\(+/, '')

        subquery_sql = Arel.sql("(#{sql}) as #{SUBQUERY_NAME}")

        arel_filters = build_filters_arel(filters)

        rel = connection_class.from(subquery_sql)
                              .select(Arel::Table.new(SUBQUERY_NAME)[Arel.star])
                              .where(arel_filters)

        rel = rel.limit(limit.to_i) unless connection_class.connection.class.name.include?('SQLServerAdapter')

        rel.to_sql
      end

      # @param filters [Hash]
      # @return [Arel::Nodes, nil]
      def build_filters_arel(filters)
        return nil if filters.blank?

        table = Arel::Table.new(SUBQUERY_NAME)

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

        sql = ActiveRecord::Base.send(:replace_bind_variables,
                                      sql.gsub(STATEMENT_VARIABLE_REGEXP, '?'),
                                      attributes.map(&:value))

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
        @connection_class ||=
          'ResourceRecord'.safe_constantize ||
          'ApplicationRecord'.safe_constantize ||
          Class.new(ActiveRecord::Base).tap { |e| e.abstract_class = true }
      end
    end
  end
end
