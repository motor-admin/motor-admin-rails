# frozen_string_literal: true

module Motor
  module LoadAndAuthorizeDynamicResource
    extend ActiveSupport::Concern

    INSTANCE_VARIABLE_NAME = 'resource'

    included do
      before_action :load_and_authorize_resource
      before_action :load_and_authorize_association
    end

    def resource_class
      @resource_class ||=
        Motor::BuildSchema::Utils.classify_slug(resource_name_prefix + params[:resource])
    end

    def resource_name_prefix
      ''
    end

    def load_and_authorize_resource
      options = {
        class: resource_class,
        parent: false,
        instance_name: INSTANCE_VARIABLE_NAME
      }

      if params[:resource_id].present?
        options = options.merge(
          parent: true,
          id_param: :resource_id
        )
      end

      CanCan::ControllerResource.new(
        self,
        options
      ).load_and_authorize_resource
    rescue ActiveRecord::RecordNotFound
      head :not_found
    rescue StandardError => e
      render json: { errors: [e.message] }, status: :unprocessable_entity
    end

    def load_and_authorize_association
      return if params[:association].blank?

      association = resource_class.reflections[params[:association]]

      if association
        CanCan::ControllerResource.new(
          self,
          class: association.klass,
          parent: false,
          through: :resource,
          through_association: params[:association].to_sym,
          instance_name: INSTANCE_VARIABLE_NAME
        ).load_and_authorize_resource
      else
        render json: { message: 'Unknown association' }, status: :not_found
      end
    rescue ActiveRecord::RecordNotFound
      head :not_found
    rescue StandardError => e
      render json: { errors: [e.message] }, status: :unprocessable_entity
    end
  end
end
