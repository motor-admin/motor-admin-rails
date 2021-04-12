# frozen_string_literal: true

module Motor
  class ResourcesController < ApiBaseController
    load_and_authorize_resource

    def index
      render json: { data: Motor::ApiQuery::BuildJson.call(@resources, params) }
    end

    def create
      Motor::BuildSchema::PersistResourceConfigs.call(@resource)

      render json: { data: Motor::ApiQuery::BuildJson.call(@resource, params) }
    end

    private

    def resource_params
      params.require(:data).permit!
    end
  end
end
