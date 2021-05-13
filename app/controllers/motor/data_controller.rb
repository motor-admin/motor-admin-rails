# frozen_string_literal: true

module Motor
  class DataController < ApiBaseController
    wrap_parameters :data, except: %i[include fields]

    include Motor::WrapIoParams
    include Motor::LoadAndAuthorizeDynamicResource

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
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @resource.errors }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { errors: [e.message] }, status: :unprocessable_entity
    end

    def update
      @resource.update!(resource_params)

      render json: { data: Motor::ApiQuery::BuildJson.call(@resource, params) }
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @resource.errors }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { errors: [e.message] }, status: :unprocessable_entity
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
      @resource.public_send(params[:method].to_sym)

      head :ok
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end

    private

    def resource_params
      if params[:data].present?
        params.require(:data).except(resource_class.primary_key).permit!
      else
        {}
      end
    end
  end
end
