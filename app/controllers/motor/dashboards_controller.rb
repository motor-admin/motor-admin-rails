# frozen_string_literal: true

module Motor
  class DashboardsController < ApiBaseController
    load_and_authorize_resource :dashboard

    def index
      render json: { data: Motor::ApiQuery::BuildJson.call(@dashboards, params) }
    end

    def show
      render json: { data: Motor::ApiQuery::BuildJson.call(@dashboard, params) }
    end

    def create
      @dashboard.save!

      render json: { data: Motor::ApiQuery::BuildJson.call(@dashboard, params) }
    end

    def update
      @dashboard.update!(dashboard_params)

      render json: { data: Motor::ApiQuery::BuildJson.call(@dashboard, params) }
    end

    def destroy
      @dashboard.update!(deleted_at: Time.current)

      head :ok
    end

    private

    def dashboard_params
      params.require(:data).permit(:title, preferences: {}, tags: [])
    end
  end
end
