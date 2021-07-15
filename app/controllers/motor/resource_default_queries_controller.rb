# frozen_string_literal: true

module Motor
  class ResourceDefaultQueriesController < ApiBaseController
    skip_authorization_check

    before_action :authorize_resource

    def show
      render json: { data: { sql: resource_class.all.to_sql } }
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
