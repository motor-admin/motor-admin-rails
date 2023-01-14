# frozen_string_literal: true

module Motor
  module Configs
    module BuildUiAppTag
      CACHE_STORE =
        if Motor.development?
          ActiveSupport::Cache::NullStore.new
        else
          ActiveSupport::Cache::MemoryStore.new(size: 5.megabytes)
        end

      module_function

      def call(current_user = nil, current_ability = nil, cache_keys: LoadFromCache.load_cache_keys)
        CACHE_STORE.fetch(app_tag_cache_key(cache_keys, current_user, current_ability)) do
          CACHE_STORE.clear

          data = build_data(cache_keys, current_user, current_ability)
          Motor::ApplicationController.helpers.tag.div('', id: 'app', data: data)
        end
      end

      def app_tag_cache_key(cache_keys, current_user, current_ability)
        key = "#{I18n.locale}#{cache_keys.hash}#{current_user&.id}#{current_ability&.rules_hash}"

        key += Motor::DefineArModels.defined_models_schema_md5.to_s if defined?(Motor::DefineArModels)

        if Rails.env.development?
          key += Digest::MD5.hexdigest(ActiveRecord::Base.descendants.map(&:object_id).sort.join)
        end

        key
      end

      # rubocop:disable Metrics/AbcSize
      # @return [Hash]
      def build_data(cache_keys = {}, current_user = nil, current_ability = nil)
        configs_cache_key = cache_keys[:configs]

        { version: Motor::VERSION,
          current_user: serialize_current_user(current_user),
          current_rules: current_ability.serialized_rules,
          audits_count: Motor::Audit.count,
          i18n: i18n_data,
          base_path: Motor::Admin.routes.url_helpers.motor_path,
          cable_path: Motor::Admin.routes.url_helpers.try(:motor_cable_path),
          admin_settings_path: Rails.application.routes.url_helpers.try(:admin_settings_general_path),
          schema: Motor::BuildSchema.call(cache_keys, current_ability),
          header_links: header_links_data_hash(current_user, current_ability, configs_cache_key),
          homepage_layout: homepage_layout_data_hash(configs_cache_key),
          databases: database_names,
          queries: queries_data_hash(build_cache_key(cache_keys, :queries, current_user, current_ability),
                                     current_ability),
          dashboards: dashboards_data_hash(build_cache_key(cache_keys, :dashboards, current_user, current_ability),
                                           current_ability),
          alerts: alerts_data_hash(build_cache_key(cache_keys, :alerts, current_user, current_ability),
                                   current_ability),
          forms: forms_data_hash(build_cache_key(cache_keys, :forms, current_user, current_ability), current_ability) }
      end
      # rubocop:enable Metrics/AbcSize

      def i18n_data
        I18n.t('motor', default: I18n.t('motor', locale: :en))
      end

      def serialize_current_user(user)
        return unless user

        attrs = user.as_json(only: %i[id email first_name last_name])

        attrs['role'] = user.role if user.respond_to?(:role)
        attrs['role_names'] = user.role_names if user.respond_to?(:role_names)

        attrs
      end

      # @return [String]
      def build_cache_key(cache_keys, key, current_user, current_ability)
        "#{cache_keys[key].hash}#{current_user&.id}#{current_ability&.rules_hash}"
      end

      def header_links_data_hash(current_user, current_ability, cache_key = nil)
        configs = Motor::Configs::LoadFromCache.load_configs(cache_key: cache_key)

        links = configs.find { |c| c.key == 'header.links' }&.value || []
        links = add_default_links(links)

        return links unless current_user
        return links if current_ability.can?(:manage, :all)

        filter_links_for_user(current_user, links)
      end

      def add_default_links(links)
        new_links = links.clone

        unless links.find { |l| l['link_type'] == 'forms' }
          new_links.unshift({ 'name' => I18n.t('motor.forms'), 'link_type' => 'forms' })
        end

        unless links.find { |l| l['link_type'] == 'reports' }
          new_links.unshift({ 'name' => I18n.t('motor.reports'), 'link_type' => 'reports' })
        end

        new_links
      end

      def filter_links_for_user(current_user, links)
        links.select do |link|
          conditions = link['conditions']

          next true if conditions.blank?

          conditions.all? do |cond|
            field_name =
              if cond['field'] == 'role' && !current_user.respond_to?(:role)
                :role_names
              else
                cond['field'].to_sym
              end

            next false unless field_name.in?(%i[email role role_names])
            next false unless current_user.respond_to?(field_name)

            Array.wrap(current_user.public_send(field_name)).intersection(Array.wrap(cond['value'])).present?
          end
        end
      end

      def homepage_layout_data_hash(cache_key = nil)
        configs = Motor::Configs::LoadFromCache.load_configs(cache_key: cache_key)

        configs.find { |c| c.key == 'homepage.layout' }&.value || []
      end

      def database_names
        if defined?(Motor::EncryptedConfig)
          Motor::DatabaseClasses.constants.map { |e| e.to_s.titleize }
        elsif ActiveRecord::Base.configurations.try(:configurations)
          ActiveRecord::Base.configurations.configurations
                            .select { |c| c.env_name == Rails.env }
                            .map { |c| c.try(:name) || c.try(:spec_name) }.compact
        else
          ['primary']
        end
      end

      def queries_data_hash(cache_key = nil, current_ability = nil)
        Motor::Configs::LoadFromCache.load_queries(cache_key: cache_key, current_ability: current_ability)
                                     .as_json(only: %i[id name updated_at],
                                              include: { tags: { only: %i[id name] } })
      end

      def dashboards_data_hash(cache_key = nil, current_ability = nil)
        Motor::Configs::LoadFromCache.load_dashboards(cache_key: cache_key, current_ability: current_ability)
                                     .as_json(only: %i[id title updated_at],
                                              include: { tags: { only: %i[id name] } })
      end

      def alerts_data_hash(cache_key = nil, current_ability = nil)
        Motor::Configs::LoadFromCache.load_alerts(cache_key: cache_key, current_ability: current_ability)
                                     .as_json(only: %i[id name is_enabled updated_at],
                                              include: { tags: { only: %i[id name] } })
      end

      def forms_data_hash(cache_key = nil, current_ability = nil)
        Motor::Configs::LoadFromCache.load_forms(cache_key: cache_key, current_ability: current_ability)
                                     .as_json(only: %i[id name updated_at],
                                              include: { tags: { only: %i[id name] } })
      end
    end
  end
end
