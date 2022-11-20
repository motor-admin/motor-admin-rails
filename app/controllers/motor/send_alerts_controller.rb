# frozen_string_literal: true

module Motor
  class SendAlertsController < ApiBaseController
    wrap_parameters :data

    before_action :build_alert, only: :create
    authorize_resource :alert, only: :create

    def create
      Motor::Alerts.send_alert(@alert)

      head :ok
    end

    private

    def build_alert
      @alert = Motor::Alerts::Persistance.build_from_params(alert_params)
    end

    def alert_params
      params.require(:data).permit(:query_id, :name, :to_emails, :description, preferences: {})
    end
  end
end
