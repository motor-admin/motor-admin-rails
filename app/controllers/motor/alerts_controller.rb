# frozen_string_literal: true

module Motor
  class AlertsController < ApiBaseController
    wrap_parameters :data, except: %i[include fields]

    load_and_authorize_resource :alert, only: %i[index show update destroy]

    before_action :build_alert, only: :create
    authorize_resource :alert, only: :create

    def index
      render json: { data: Motor::ApiQuery::BuildJson.call(@alerts.active, params, current_ability) }
    end

    def show
      render json: { data: Motor::ApiQuery::BuildJson.call(@alert, params, current_ability) }
    end

    def create
      if Motor::Alerts::Persistance.name_already_exists?(@alert)
        name_already_exists_response
      else
        ApplicationRecord.transaction { @alert.save! }
        Motor::Alerts::ScheduledAlertsCache.clear
        Motor::Configs::WriteToFile.call

        render json: { data: Motor::ApiQuery::BuildJson.call(@alert, params, current_ability) }
      end
    rescue Motor::Alerts::Persistance::InvalidInterval
      invalid_interval_response
    end

    def update
      Motor::Alerts::Persistance.update_from_params!(@alert, alert_params)
      Motor::Alerts::ScheduledAlertsCache.clear
      Motor::Configs::WriteToFile.call

      render json: { data: Motor::ApiQuery::BuildJson.call(@alert, params, current_ability) }
    rescue Motor::Alerts::Persistance::NameAlreadyExists
      name_already_exists_response
    rescue Motor::Alerts::Persistance::InvalidInterval
      invalid_interval_response
    end

    def destroy
      @alert.update!(deleted_at: Time.current)

      Motor::Configs::WriteToFile.call

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
