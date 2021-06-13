# frozen_string_literal: true

module Motor
  class DashboardsController < ApiBaseController
    wrap_parameters :data, except: %i[include fields]

    load_and_authorize_resource :dashboard, only: %i[index show update destroy]

    before_action :build_dashboard, only: :create
    authorize_resource :dashboard, only: :create

    def index
      render json: { data: Motor::ApiQuery::BuildJson.call(@dashboards.active, params, current_ability) }
    end

    def show
      render json: { data: Motor::ApiQuery::BuildJson.call(@dashboard, params, current_ability) }
    end

    def create
      if Motor::Dashboards::Persistance.title_already_exists?(@dashboard)
        render json: { errors: [{ source: 'title', detail: 'Title already exists' }] }, status: :unprocessable_entity
      else
        ApplicationRecord.transaction { @dashboard.save! }
        Motor::Configs::WriteToFile.call

        render json: { data: Motor::ApiQuery::BuildJson.call(@dashboard, params, current_ability) }
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def update
      Motor::Dashboards::Persistance.update_from_params!(@dashboard, dashboard_params)
      Motor::Configs::WriteToFile.call

      render json: { data: Motor::ApiQuery::BuildJson.call(@dashboard, params, current_ability) }
    rescue Motor::Dashboards::Persistance::TitleAlreadyExists
      render json: { errors: [{ source: 'title', detail: 'Title already exists' }] }, status: :unprocessable_entity
    end

    def destroy
      @dashboard.update!(deleted_at: Time.current)

      Motor::Configs::WriteToFile.call

      head :ok
    end

    private

    def build_dashboard
      @dashboard = Motor::Dashboards::Persistance.build_from_params(dashboard_params)

      @dashboard.define_singleton_method(:tags) do
        taggable_tags.map(&:tag)
      end
    end

    def dashboard_params
      params.require(:data).permit(:title, :description, preferences: {}, tags: [])
    end
  end
end
