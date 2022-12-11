# frozen_string_literal: true

module Motor
  class DataController < ApiBaseController
    wrap_parameters :data, except: %i[include fields]

    include Motor::WrapIoParams
    include Motor::LoadAndAuthorizeDynamicResource

    def index
      @resources = Motor::ApiQuery.call(@resources, params)

      if params[:format] == 'csv'
        render plain: Motor::ActiveRecordUtils.generate_csv_for_relation(@resources, reset_limit: true)
      else
        render json: {
          data: Motor::ApiQuery::BuildJson.call(@resources, params, current_ability),
          meta: Motor::ApiQuery::BuildMeta.call(@resources, params)
        }
      end
    end

    def show
      render json: { data: Motor::ApiQuery::BuildJson.call(@resource, params, current_ability) }
    end

    def create
      if @associated_resource
        if @resource_class.reflections[params[:association]].through_reflection?
          @associated_resource.save!

          @resource = @associated_resource
        else
          @resource.public_send(params[:association].to_sym).create!(resource_params) do |resource|
            @resource = resource
          end
        end
      else
        @resource.save!
      end

      render json: { data: Motor::ApiQuery::BuildJson.call(@resource, params, current_ability) }
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @resource.errors }, status: :unprocessable_entity
    end

    def update
      @resource.update!(resource_params)

      render json: { data: Motor::ApiQuery::BuildJson.call(@resource, params, current_ability) }
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @resource.errors }, status: :unprocessable_entity
    end

    def destroy
      if @resource.respond_to?(:deleted_at)
        @resource.update(deleted_at: Time.current)
      else
        @resource.destroy!
      end

      head :ok
    end

    def execute
      resource_preferences = Motor::Resource.find_by(name: @resource.class.name.underscore).preferences
      resource_action = resource_preferences[:actions].find { |a| a.dig(:preferences, :method_name) == params[:method] }

      authorize!(resource_action[:name].to_sym, @resource)

      @resource.public_send(params[:method].to_sym)

      head :ok
    end

    private

    def resource_params
      if params[:data].present?
        params.require(:data).permit!
      else
        {}
      end
    end
  end
end
