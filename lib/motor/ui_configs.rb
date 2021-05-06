# frozen_string_literal: true

module Motor
  module UiConfigs
    CACHE_STORE =
      if Motor.development?
        ActiveSupport::Cache::NullStore.new
      else
        ActiveSupport::Cache::MemoryStore.new(size: 5.megabytes)
      end

    module_function

    # @return [String]
    def app_tag
      CACHE_STORE.fetch(cache_key) do
        CACHE_STORE.clear

        Motor::ApplicationController.helpers.content_tag(
          :div, '', id: 'app', data: ui_data
        )
      end
    end

    # @return [Hash]
    def ui_data
      {
        base_path: Motor::Admin.routes.url_helpers.motor_path,
        schema: Motor::BuildSchema.call,
        header_links: header_links_data_hash,
        queries: queries_data_hash,
        dashboards: dashboards_data_hash,
        alerts: alerts_data_hash,
        forms: forms_data_hash
      }
    end

    def header_links_data_hash
      Motor::Config.find_by(key: 'header.links')&.value || []
    end

    def queries_data_hash
      Motor::Query.all.active.preload(:tags)
                  .as_json(only: %i[id name updated_at],
                           include: { tags: { only: %i[id name] } })
    end

    def dashboards_data_hash
      Motor::Dashboard.all.active.preload(:tags)
                      .as_json(only: %i[id title updated_at],
                               include: { tags: { only: %i[id name] } })
    end

    def alerts_data_hash
      Motor::Alert.all.active.preload(:tags)
                  .as_json(only: %i[id name is_enabled updated_at],
                           include: { tags: { only: %i[id name] } })
    end

    def forms_data_hash
      Motor::Form.all.active.preload(:tags)
                 .as_json(only: %i[id name updated_at],
                          include: { tags: { only: %i[id name] } })
    end

    # @return [String]
    def cache_key
      ActiveRecord::Base.connection.execute(
        "(#{
          [
            Motor::Config.select('MAX(updated_at)').to_sql,
            Motor::Resource.select('MAX(updated_at)').to_sql,
            Motor::Dashboard.select('MAX(updated_at)').to_sql,
            Motor::Alert.select('MAX(updated_at)').to_sql,
            Motor::Query.select('MAX(updated_at)').to_sql,
            Motor::Form.select('MAX(updated_at)').to_sql
          ].join(') UNION (')
        })"
      ).to_a.hash.to_s
    end
  end
end
