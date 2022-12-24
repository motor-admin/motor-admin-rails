# frozen_string_literal: true

module Motor
  module Configs
    module LoadFromCache
      CACHE_HASH = ActiveSupport::HashWithIndifferentAccess.new

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
          Motor::Config.all.load
        end
      end

      def load_resources(cache_key: nil)
        maybe_fetch_from_cache('resources', cache_key) do
          Motor::Resource.all.load
        end
      end

      def load_queries(cache_key: nil, current_ability: nil)
        maybe_fetch_from_cache('queries', cache_key) do
          rel = Motor::Query.all.active.preload(:tags)
          rel = rel.accessible_by(current_ability) if current_ability

          rel.load
        end
      end

      def load_dashboards(cache_key: nil, current_ability: nil)
        maybe_fetch_from_cache('dashboards', cache_key) do
          rel = Motor::Dashboard.all.active.preload(:tags)
          rel = rel.accessible_by(current_ability) if current_ability

          rel.load
        end
      end

      def load_alerts(cache_key: nil, current_ability: nil)
        maybe_fetch_from_cache('alerts', cache_key) do
          rel = Motor::Alert.all.active.preload(:tags)
          rel = rel.accessible_by(current_ability) if current_ability

          rel.load
        end
      end

      def load_forms(cache_key: nil, current_ability: nil)
        maybe_fetch_from_cache('forms', cache_key) do
          rel = Motor::Form.all.active.preload(:tags)
          rel = rel.accessible_by(current_ability) if current_ability

          rel.load
        end
      end

      def load_api_configs(cache_key: nil)
        maybe_fetch_from_cache('forms', cache_key) do
          Motor::ApiConfig.all.active.load
        end
      end

      def maybe_fetch_from_cache(type, cache_key)
        return yield unless cache_key

        if CACHE_HASH[type] && CACHE_HASH[type][:key] == cache_key
          CACHE_HASH[type][:value]
        else
          result = yield

          CACHE_HASH[type] = { key: cache_key, value: result }

          result
        end
      end

      def load_cache_keys
        result = ActiveRecord::Base.connection.exec_query(cache_keys_sql).rows

        result.to_h.with_indifferent_access
      end

      def cache_keys_sql
        [
          Motor::Config.select("'configs', MAX(updated_at)").to_sql,
          Motor::Resource.select("'resources', MAX(updated_at)").to_sql,
          Motor::Dashboard.select("'dashboards', MAX(updated_at)").to_sql,
          Motor::Alert.select("'alerts', MAX(updated_at)").to_sql,
          Motor::Query.select("'queries', MAX(updated_at)").to_sql,
          Motor::Form.select("'forms', MAX(updated_at)").to_sql,
          Motor::ApiConfig.select("'api_configs', MAX(updated_at)").to_sql
        ].join(' UNION ')
      end
    end
  end
end
