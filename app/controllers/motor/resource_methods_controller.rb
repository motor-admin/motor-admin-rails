# frozen_string_literal: true

module Motor
  class ResourceMethodsController < ApiBaseController
    skip_authorization_check

    before_action :authorize_resource

    def show
      render json: { data: ActiveRecordUtils::FetchMethods.call(resource_class) }
    end

    private

    def resource_class
      @resource_class ||= Motor::BuildSchema::Utils.classify_slug(params[:resource])
    end

    def authorize_resource
      authorize!(resource_class, :manage)
    end
  end
end
