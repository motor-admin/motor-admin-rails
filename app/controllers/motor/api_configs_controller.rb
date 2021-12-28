# frozen_string_literal: true

module Motor
  class ApiConfigsController < ApiBaseController
    wrap_parameters :data, except: %i[include fields]

    before_action :find_or_initialize_api_config, only: :create
    load_and_authorize_resource

    def index
      render json: { data: Motor::ApiQuery::BuildJson.call(@api_configs.active.order(:id), params, current_ability) }
    end

    def create
      @api_config.save!

      Motor::Configs::WriteToFile.call

      render json: { data: Motor::ApiQuery::BuildJson.call(@api_config, params, current_ability) }
    rescue ActiveRecord::RecordNotUnique
      find_or_initialize_api_config

      retry
    end

    def destroy
      @api_config&.update!(deleted_at: Time.current)

      Motor::Configs::WriteToFile.call

      head :ok
    end

    private

    def find_or_initialize_api_config
      name, url, description, preferences, credentials =
        api_config_params.values_at(:name, :url, :description, :preferences, :credentials)

      @api_config =
        Motor::ApiConfig.find_or_initialize_by(name: name).tap do |config|
          config.url = url.delete_suffix('/')
          config.description = description
          config.preferences.merge!(preferences)
          config.credentials.merge!(credentials)
          config.deleted_at = nil
        end
    end

    def api_config_params
      params.require(:data).permit(:name, :url, :description, preferences: {}, credentials: {})
    end
  end
end
