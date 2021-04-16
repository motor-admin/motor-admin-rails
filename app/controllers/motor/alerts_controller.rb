# frozen_string_literal: true

module Motor
  class AlertsController < ApiBaseController
    load_and_authorize_resource :alert, only: %i[index show update destroy]

    before_action :build_alert, only: :create
    authorize_resource :alert, only: :create

    def index
      render json: { data: Motor::ApiQuery::BuildJson.call(@alerts.active, params) }
    end

    def show
      render json: { data: Motor::ApiQuery::BuildJson.call(@alert, params) }
    end

    def create
      ApplicationRecord.transaction { @alert.save! }
      Motor::Alerts::ScheduledAlertsCache.clear

      render json: { data: Motor::ApiQuery::BuildJson.call(@alert, params) }
    rescue Motor::Alerts::Persistance::NameAlreadyExists
      name_already_exists_response
    rescue Motor::Alerts::Persistance::InvalidInterval
      invalid_interval_response
    end

    def update
      Motor::Alerts::Persistance.update_from_params!(@alert, alert_params)
      Motor::Alerts::ScheduledAlertsCache.clear

      render json: { data: Motor::ApiQuery::BuildJson.call(@alert, params) }
    rescue Motor::Alerts::Persistance::NameAlreadyExists
      name_already_exists_response
    rescue Motor::Alerts::Persistance::InvalidInterval
      invalid_interval_response
    end

    def destroy
      @alert.update!(deleted_at: Time.current)

      head :ok
    end

    private

    def name_already_exists_response
      render json: { errors: [{ source: 'name', detail: 'Name already exists' }] },
             status: :unprocessable_entity
    end

    def invalid_interval_response
      render json: { errors: [{ source: 'preferences.interval', detail: 'Invalid interval' }] },
             status: :unprocessable_entity
    end

    def build_alert
      @alert = Motor::Alerts::Persistance.build_from_params(alert_params)
    end

    def alert_params
      params.require(:data).permit(
        :query_id,
        :name,
        :description,
        :to_emails,
        :is_enabled,
        preferences: {},
        tags: []
      )
    end
  end
end
