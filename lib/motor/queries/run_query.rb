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

      DATABASE_URL_VARIABLE_SUFFIX = '_database_url'

      DB_LINK_VALIDATE_REGEXP = /(.*?)\s*\{\{\s*\w+_database_url\s*\}\}/i.freeze

      UnknownDatabase = Class.new(StandardError)
      UnsafeDatabaseUrlUsage = Class.new(StandardError)

      module_function

      # @param query [Motor::Query]
      # @param variables_hash [Hash]
      # @param limit [Integer]
      # @param filters [Hash]
      # @return [Motor::Queries::RunQuery::QueryResult]
      def call!(query, variables_hash: nil, limit: nil, filters: nil)
        variables_hash ||= {}
        variables_hash = variables_hash.with_indifferent_access
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

        connection_class = fetch_connection_class(query)

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

      def validate_query!(sql)
        return if sql.scan(DB_LINK_VALIDATE_REGEXP).flatten.all? { |line| line.ends_with?('dblink(') }

        raise UnsafeDatabaseUrlUsage, 'Database URL variable is allowed only with dblink'
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

        validate_query!(query.sql_body)

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
        sql = normalize_sql(sql)

        subquery_sql = Arel.sql("(#{sql})").as(connection_class.connection.quote_column_name(SUBQUERY_NAME))

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
            val = fetch_variable_database_url(variable_name) if variable_name.ends_with?(DATABASE_URL_VARIABLE_SUFFIX)

            ActiveRecord::Relation::QueryAttribute.new(
              variable_name,
              val,
              ActiveRecord::Type::Value.new
            )
          end
        end.flatten
      end

      def fetch_variable_database_url(variable_name)
        class_name = variable_name.delete_suffix(DATABASE_URL_VARIABLE_SUFFIX).classify

        Motor::DatabaseClasses.const_get(class_name).connection_db_config.url
      rescue NameError
        raise UnknownDatabase, "#{class_name} database is not defined"
      end

      # @param array [Array]
      # @return [Array]
      def normalize_statement_for_sql(statement)
        sql, _, attributes = statement

        sql = ActiveRecord::Base.send(:replace_bind_variables,
                                      sql.gsub(STATEMENT_VARIABLE_REGEXP, '?'),
                                      attributes.map(&:value))

        [sql, 'SQL', []]
      end

      def normalize_sql(sql)
        sql.strip.delete_suffix(';').gsub(/\A\)+/, '').gsub(/\z\(+/, '')
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

      def fetch_connection_class(query)
        database_name = query.preferences[:database]

        return default_connection_class if database_name.blank? || database_name == 'default'

        return default_connection_class if database_name == 'primary'

        ar_configurations = ActiveRecord::Base.configurations.configurations
                                              .find { |c| c.name == database_name && c.env_name == Rails.env }

        if ar_configurations
          fetch_ar_configurations_connection(database_name, ar_configurations)
        else
          Motor::DatabaseClasses.const_get(database_name.sub(/\A\d+/, '').parameterize.underscore.classify)
        end
      end

      def fetch_ar_configurations_connection(database_name, ar_configurations)
        Motor::DatabaseClasses.const_get(database_name.classify)
      rescue NameError
        klass = Class.new(ActiveRecord::Base)

        Motor::DatabaseClasses.const_set(database_name.classify, klass)

        klass.establish_connection(ar_configurations.name.to_sym)

        klass
      end

      def find_connection_in_pool(database_name)
        ActiveRecord::Base.connection_pool.connections.find do |conn|
          conn.pool.db_config.name == database_name
        end
      end

      def default_connection_class
        'ResourceRecord'.safe_constantize ||
          'ApplicationRecord'.safe_constantize ||
          Class.new(ActiveRecord::Base).tap { |e| e.abstract_class = true }
      end
    end
  end
end
