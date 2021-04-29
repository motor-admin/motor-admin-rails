# frozen_string_literal: true

module Motor
  class RunQueriesController < ApiBaseController
    wrap_parameters :data

    load_and_authorize_resource :query, only: :show, parent: false

    before_action :build_query, only: :create
    authorize_resource :query, only: :create

    rescue_from 'ActiveRecord::StatementInvalid' do |e|
      render json: { errors: [{ detail: e.message }] }, status: :unprocessable_entity
    end

    def show
      render json: query_result_hash(query_result)
    end

    def create
      render json: query_result_hash(query_result)
    end

    private

    def query_result
      Queries::RunQuery.call(@query, variables_hash: params[:variables])
    end

    def query_result_hash(query_result)
      {
        data: query_result.data,
        meta: {
          columns: query_result.columns
        }
      }
    end

    def build_query
      @query = Motor::Queries::Persistance.build_from_params(query_params)
    end

    def query_params
      params.require(:data).permit(:sql_body, preferences: {})
    end
  end
end
