# frozen_string_literal: true

module Motor
  class ConfigsController < ApiBaseController
    wrap_parameters :data, except: %i[include fields]

    load_and_authorize_resource

    def index
      render json: { data: Motor::ApiQuery::BuildJson.call(@configs, params) }
    end

    def create
      @config =
        Motor::Config.find_or_initialize_by(key: @config.key).tap do |config|
          config.value = @config.value
        end

      @config.save!

      render json: { data: Motor::ApiQuery::BuildJson.call(@config, params) }
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    private

    def config_params
      params.require(:data).permit!
    end
  end
end
