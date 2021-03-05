module Motor
  class ResourcesController < ActionController::API
    INSTANCE_VARIABLE_NAME = 'resource'

    before_action :load_and_authorize_resource

    def index
      render json: @resources.limit(20)
    end

    def show
      render json: @resource
    end

    def create
      @resource.save!

      render json: @resource
    end

    def update
      @resource.update!(params)

      render json: @resource
    end

    def destroy
      @resource.destroy

      head :ok
    end

    private

    def load_and_authorize_resource
      resource_name = params[:resource].singularize

      cancan =
        CanCan::ControllerResource.new(self,
                                       resource_name.to_sym,
                                       class: resource_name.classify.constantize,
                                       parent: false,
                                       name: resource_name,
                                       instance_name: INSTANCE_VARIABLE_NAME)

      cancan.load_and_authorize_resource
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
