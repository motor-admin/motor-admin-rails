# frozen_string_literal: true

module Motor
  class DataController < ApiBaseController
    INSTANCE_VARIABLE_NAME = 'resource'

    before_action :load_and_authorize_resource
    before_action :load_and_authorize_association

    def index
      @resources = Motor::ApiQuery.call(@resources, params)

      render json: {
        data: Motor::ApiQuery::BuildJson.call(@resources, params),
        meta: Motor::ApiQuery::BuildMeta.call(@resources, params)
      }
    end

    def show
      render json: { data: Motor::ApiQuery::BuildJson.call(@resource, params) }
    end

    def create
      @resource.save!

      render json: { data: Motor::ApiQuery::BuildJson.call(@resource, params) }
    end

    def update
      @resource.update!(resource_params)

      render json: { data: Motor::ApiQuery::BuildJson.call(@resource, params) }
    end

    def destroy
      if @resource.respond_to?(:deleted_at)
        @resource.update(deleted_at: Time.current)
      else
        @resource.destroy!
      end

      head :ok
    end

    private

    def resource_class
      @resource_class ||= Motor::BuildSchema::Utils.classify_slug(params[:resource])
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
    end

    def current_ability
      klass = Class.new
      klass.include(CanCan::Ability)
      klass.define_method(:initialize) do |_user|
        can :manage, :all
      end

      klass.new(current_user)
    end

    def resource_params
      params.fetch(:data, {}).except(resource_class.primary_key).permit!
    end
  end
end
