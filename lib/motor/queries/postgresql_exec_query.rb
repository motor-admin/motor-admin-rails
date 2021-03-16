# frozen_string_literal: true

module Motor
  module Queries
    module PostgresqlExecQuery
      module_function

      def call(conn, statement)
        conn.send(:execute_and_clear, *statement) do |result|
          types = {}
          fields = result.fields

          fields.each_with_index do |fname, i|
            ftype = result.ftype i
            fmod  = result.fmod i
            types[fname] = conn.send(:get_oid_type, ftype, fmod, fname)
          end

          conn.send(:build_result, columns: fields, rows: result.values, column_types: types)
        end
      end
    end
  end
end
