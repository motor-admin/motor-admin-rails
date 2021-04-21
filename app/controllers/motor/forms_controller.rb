# frozen_string_literal: true

module Motor
  class FormsController < ApiBaseController
    load_and_authorize_resource :form, only: %i[index show update destroy]

    before_action :build_form, only: :create
    authorize_resource :form, only: :create

    def index
      render json: { data: Motor::ApiQuery::BuildJson.call(@forms.active, params) }
    end

    def show
      render json: { data: Motor::ApiQuery::BuildJson.call(@form, params) }
    end

    def create
      if Motor::Forms::Persistance.name_already_exists?(@form)
        render json: { errors: [{ source: 'name', detail: 'Name already exists' }] }, status: :unprocessable_entity
      else
        ApplicationRecord.transaction { @form.save! }

        render json: { data: Motor::ApiQuery::BuildJson.call(@form, params) }
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def update
      Motor::Forms::Persistance.update_from_params!(@form, form_params)

      render json: { data: Motor::ApiQuery::BuildJson.call(@form, params) }
    rescue Motor::Forms::Persistance::NameAlreadyExists
      render json: { errors: [{ source: 'name', detail: 'Name already exists' }] }, status: :unprocessable_entity
    end

    def destroy
      @form.update!(deleted_at: Time.current)

      head :ok
    end

    private

    def build_form
      @form = Motor::Forms::Persistance.build_from_params(form_params)
    end

    def form_params
      params.require(:data).permit(:name, :description, :api_path, :http_method, preferences: {}, tags: [])
    end
  end
end
