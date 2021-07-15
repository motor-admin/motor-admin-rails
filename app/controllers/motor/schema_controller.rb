# frozen_string_literal: true

module Motor
  class SchemaController < ApiBaseController
    skip_authorization_check

    before_action :authorize_resource, only: :show

    def index
      render json: { data: schema }
    end

    def show
      render json: { data: schema.find { |model| model[:name] == resource_class.name.underscore } }
    end

    private

    def schema
      @schema ||= Motor::BuildSchema.call(Configs::LoadFromCache.load_cache_keys, current_ability)
    end

    def resource_class
      @resource_class ||= Motor::BuildSchema::Utils.classify_slug(params[:resource])
    end

    def authorize_resource
      authorize!(resource_class, :read)
    end
  end
end
