# frozen_string_literal: true

module Motor
  class FormsController < ApiBaseController
    wrap_parameters :data, except: %i[include fields]

    load_and_authorize_resource :form, only: %i[index show update destroy]

    before_action :build_form, only: :create
    authorize_resource :form, only: :create

    def index
      render json: { data: Motor::ApiQuery::BuildJson.call(@forms.active, params, current_ability) }
    end

    def show
      render json: { data: Motor::ApiQuery::BuildJson.call(@form, params, current_ability) }
    end

    def create
      if Motor::Forms::Persistance.name_already_exists?(@form)
        render json: { errors: [{ source: 'name', detail: 'Name already exists' }] }, status: :unprocessable_entity
      else
        ApplicationRecord.transaction { @form.save! }
        Motor::Configs::WriteToFile.call

        render json: { data: Motor::ApiQuery::BuildJson.call(@form, params, current_ability) }
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def update
      Motor::Forms::Persistance.update_from_params!(@form, form_params)
      Motor::Configs::WriteToFile.call

      render json: { data: Motor::ApiQuery::BuildJson.call(@form, params, current_ability) }
    rescue Motor::Forms::Persistance::NameAlreadyExists
      render json: { errors: [{ source: 'name', detail: 'Name already exists' }] }, status: :unprocessable_entity
    end

    def destroy
      @form.update!(deleted_at: Time.current)

      Motor::Configs::WriteToFile.call

      head :ok
    end

    private

    def build_form
      @form = Motor::Forms::Persistance.build_from_params(form_params)
    end

    def form_params
      params.require(:data).permit(:name, :description, :api_path, :http_method,
                                   :api_config_name, preferences: {}, tags: [])
    end
  end
end
