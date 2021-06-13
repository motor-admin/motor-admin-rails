# frozen_string_literal: true

module Motor
  class AuditsController < ApiBaseController
    load_and_authorize_resource :audit

    def index
      audits = Motor::ApiQuery.call(@audits, params)

      render json: {
        data: Motor::ApiQuery::BuildJson.call(audits, params, current_ability),
        meta: Motor::ApiQuery::BuildMeta.call(audits, params)
      }
    end
  end
end
