# frozen_string_literal: true

module Motor
  module Resources
    module CustomSqlColumnsCache
      CACHE_STORE = ActiveSupport::Cache::MemoryStore.new(size: 5.megabytes)

      module_function

      def call(sql)
        CACHE_STORE.fetch(sql.hash) do
          Queries::RunQuery.call(Query.new(sql_body: sql), limit: 0).columns || []
        end
      end
    end
  end
end
