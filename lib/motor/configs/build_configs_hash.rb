# frozen_string_literal: true

module Motor
  module Configs
    module BuildConfigsHash
      module_function

      def call
        cache_keys = LoadFromCache.load_cache_keys

        normalize_hash(
          engine_version: Motor::VERSION,
          file_version: cache_keys.values.compact.max.to_time,
          resources: build_resources_hash(cache_keys[:resources]),
          configs: build_configs_hash(cache_keys[:configs]),
          queries: build_queries_hash(cache_keys[:queries]),
          dashboards: build_dashboards_hash(cache_keys[:dashboards]),
          forms: build_forms_hash(cache_keys[:forms]),
          alerts: build_alerts_hash(cache_keys[:alerts]),
          api_configs: build_api_configs_hash(cache_keys[:api_configs])
        )
      end

      def build_queries_hash(cache_key = nil)
        Motor::Configs::LoadFromCache.load_queries(cache_key: cache_key).sort_by(&:id).map do |query|
          query.slice(%i[id name sql_body description preferences])
               .merge(tags: query.tags.map(&:name), updated_at: query.updated_at.to_time)
        end
      end

      def build_dashboards_hash(cache_key = nil)
        Motor::Configs::LoadFromCache.load_dashboards(cache_key: cache_key).sort_by(&:id).map do |dashboard|
          dashboard.slice(%i[id title description preferences])
                   .merge(tags: dashboard.tags.map(&:name), updated_at: dashboard.updated_at.to_time)
        end
      end

      def build_alerts_hash(cache_key = nil)
        Motor::Configs::LoadFromCache.load_alerts(cache_key: cache_key).sort_by(&:id).map do |alert|
          alert.slice(%i[id name query_id to_emails is_enabled description preferences])
               .merge(tags: alert.tags.map(&:name), updated_at: alert.updated_at.to_time)
        end
      end

      def build_forms_hash(cache_key = nil)
        Motor::Configs::LoadFromCache.load_forms(cache_key: cache_key).sort_by(&:id).map do |form|
          form.slice(%i[id name http_method api_path description preferences api_config_name])
              .merge(tags: form.tags.map(&:name), updated_at: form.updated_at.to_time)
        end
      end

      def build_api_configs_hash(cache_key = nil)
        Motor::Configs::LoadFromCache.load_api_configs(cache_key: cache_key).sort_by(&:id).map do |config|
          config.slice(%i[id name url preferences description]).merge(updated_at: config.updated_at.to_time)
        end
      end

      def build_configs_hash(cache_key = nil)
        Motor::Configs::LoadFromCache.load_configs(cache_key: cache_key).sort_by(&:key).map do |config|
          {
            key: config.key,
            value: config.value,
            updated_at: config.updated_at.to_time
          }
        end
      end

      def build_resources_hash(cache_key = nil)
        Motor::Configs::LoadFromCache.load_resources(cache_key: cache_key).sort_by(&:name).map do |resource|
          {
            name: resource.name,
            preferences: resource.preferences,
            updated_at: resource.updated_at.to_time
          }
        end
      end

      def normalize_hash(value)
        case value
        when Hash, ActiveSupport::HashWithIndifferentAccess
          value.to_h.stringify_keys.transform_values { |v| normalize_hash(v) }
        when Array
          value.map { |e| normalize_hash(e) }
        else
          value
        end
      end
    end
  end
end
