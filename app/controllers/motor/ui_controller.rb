# frozen_string_literal: true

module Motor
  class UiController < ApplicationController
    layout 'motor/application'

    helper_method :current_user, :current_ability, :cache_keys, :custom_html

    before_action :set_i18n_locale

    def index
      render_ui
    end

    def show
      render_ui
    end

    def new
      render_ui
    end

    private

    def render_ui
      Motor.reload! if Motor.development?

      Motor::Configs::SyncFromFile.call

      render :show
    end

    def custom_html
      Motor::Admin.config.custom_html.presence || begin
        configs = Motor::Configs::LoadFromCache.load_configs(cache_key: cache_keys[:configs])

        configs.find { |c| c.key == 'ui.custom_html' }&.value
      end
    end

    def set_i18n_locale
      configs = Motor::Configs::LoadFromCache.load_configs(cache_key: cache_keys[:configs])

      I18n.locale = configs.find { |c| c.key == 'language' }&.value&.to_sym || I18n.locale
    end

    def cache_keys
      @cache_keys ||= Configs::LoadFromCache.load_cache_keys
    end
  end
end
