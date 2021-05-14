# frozen_string_literal: true

module Motor
  module Configs
    module LoadFromCache
      CACHE_STORE = ActiveSupport::Cache::MemoryStore.new(size: 10.megabytes)

      module_function

      def call
        cache_keys = load_cache_keys

        {
          configs: load_configs(cache_key: cache_keys[:configs]),
          resources: load_resources(cache_key: cache_keys[:resources]),
          queries: load_queries(cache_key: cache_keys[:queries]),
          dashboards: load_dashboards(cache_key: cache_keys[:dashboards]),
          alerts: load_alerts(cache_key: cache_keys[:alerts]),
          forms: load_forms(cache_key: cache_keys[:forms])
        }
      end

      def load_configs(cache_key: nil)
        maybe_fetch_from_cache('configs', cache_key) do
          Motor::Config.all.to_a
        end
      end

      def load_resources(cache_key: nil)
        maybe_fetch_from_cache('resources', cache_key) do
          Motor::Resource.all.to_a
        end
      end

      def load_queries(cache_key: nil)
        maybe_fetch_from_cache('queries', cache_key) do
          Motor::Query.all.active.preload(:tags).to_a
        end
      end

      def load_dashboards(cache_key: nil)
        maybe_fetch_from_cache('dashboards', cache_key) do
          Motor::Dashboard.all.active.preload(:tags).to_a
        end
      end

      def load_alerts(cache_key: nil)
        maybe_fetch_from_cache('alerts', cache_key) do
          Motor::Alert.all.active.preload(:tags).to_a
        end
      end

      def load_forms(cache_key: nil)
        maybe_fetch_from_cache('forms', cache_key) do
          Motor::Form.all.active.preload(:tags).to_a
        end
      end

      def maybe_fetch_from_cache(type, cache_key, &block)
        return block.call unless cache_key

        CACHE_STORE.fetch(type + cache_key.to_s, &block)
      end

      def load_cache_keys
        ActiveRecord::Base.connection.execute(
          "(#{
            [
              Motor::Config.select("'configs', MAX(updated_at)").to_sql,
              Motor::Resource.select("'resources', MAX(updated_at)").to_sql,
              Motor::Dashboard.select("'dashboards', MAX(updated_at)").to_sql,
              Motor::Alert.select("'alerts', MAX(updated_at)").to_sql,
              Motor::Query.select("'queries', MAX(updated_at)").to_sql,
              Motor::Form.select("'forms', MAX(updated_at)").to_sql
            ].join(') UNION (')
          })"
        ).to_a.map(&:values).to_h.with_indifferent_access
      end
    end
  end
end
