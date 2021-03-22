# frozen_string_literal: true

module Motor
  class DashboardsController < ApiBaseController
    load_and_authorize_resource :dashboard, only: %i[index show update destroy]

    before_action :build_dashboard, only: :create
    authorize_resource :dashboard, only: :create

    def index
      render json: { data: Motor::ApiQuery::BuildJson.call(@dashboards.active, params) }
    end

    def show
      render json: { data: Motor::ApiQuery::BuildJson.call(@dashboard, params) }
    end

    def create
      if Motor::Dashboards.title_already_exists?(@dashboard)
        render json: { errors: [{ source: 'title', detail: 'Title already exists' }] }, status: :unprocessable_entity
      else
        ApplicationRecord.transaction { @dashboard.save! }

        render json: { data: Motor::ApiQuery::BuildJson.call(@dashboard, params) }
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def update
      Motor::Dashboards.update_from_params!(@dashboard, dashboard_params)

      render json: { data: Motor::ApiQuery::BuildJson.call(@dashboard, params) }
    rescue Motor::Dashboards::TitleAlreadyExists
      render json: { errors: [{ source: 'title', detail: 'Title already exists' }] }, status: :unprocessable_entity
    end

    def destroy
      @dashboard.update!(deleted_at: Time.current)

      head :ok
    end

    private

    def build_dashboard
      @dashboard = Motor::Dashboards.build_from_params(dashboard_params)
    end

    def dashboard_params
      params.require(:data).permit(:title, :description, preferences: {}, tags: [])
    end
  end
end
