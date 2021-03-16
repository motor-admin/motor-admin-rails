# frozen_string_literal: true

module Motor
  class DashboardsController < ActionController::API
    load_and_authorize_resource :dashboard

    def index
      render json: { data: @dashboards.to_json }
    end

    def show
      render json: { data: @dashboard.to_json }
    end

    def create
      @dashboard.save!

      render json: { data: @dashboard.to_json }
    end

    def update
      @dashboard.update!(dashboard_params)

      render json: { data: @dashboard.to_json }
    end

    def destroy
      @dashboard.update!(deleted_at: Time.current)

      head :ok
    end

    private

    def dashboard_params
      params.require(:data).permit(:name, :sql_body)
    end
  end
end
