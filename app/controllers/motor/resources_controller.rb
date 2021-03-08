module Motor
  class ResourcesController < ActionController::API
    INSTANCE_VARIABLE_NAME = 'resource'

    before_action :load_and_authorize_resource
    before_action :load_and_authorize_association

    def index
      @resources = Motor::Query.call(@resources, params)

      render json: {
        data: @resources,
        meta: Motor::Query::BuildMeta.call(@resources, params)
      }
    end

    def show
      render json: { data: @resource }
    end

    def create
      @resource.save!

      render json: { data: @resource }
    end

    def update
      @resource.update!(params)

      render json: { data: @resource }
    end

    def destroy
      @resource.destroy

      head :ok
    end

    private

    def load_and_authorize_resource
      resource_name = params[:resource].singularize
      resource_class = resource_name.classify.constantize

      options = {
        class: resource_class,
        parent: false,
        name: resource_name,
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
        resource_name.to_sym,
        options
      ).load_and_authorize_resource
    end

    def load_and_authorize_association
      return if params[:association].blank?

      resource_name = params[:resource].singularize
      resource_class = resource_name.classify.constantize
      association = resource_class.reflections[params[:association]]

      if association
        CanCan::ControllerResource.new(
          self,
          resource_name.to_sym,
          class: association.klass,
          parent: false,
          name: params[:association],
          through: :resource,
          through_association: params[:association].to_sym,
          instance_name: INSTANCE_VARIABLE_NAME
        ).load_and_authorize_resource
      else
        render json: { message: 'Unknown association' }, status: :not_found
      end
    end

    # def current_ability
    #   super || begin
    #     klass = Class.new
    #     klass.include(CanCan::Ability)
    #     klass.define_method(:initialize) do |user|
    #       can :manage, :all
    #     end
    #
    #     klass.new(current_user)
    #   end
    # end
  end
end
