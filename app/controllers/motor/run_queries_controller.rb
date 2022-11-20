# frozen_string_literal: true

module Motor
  class RunQueriesController < ApiBaseController
    wrap_parameters :data

    load_and_authorize_resource :query, only: :show, parent: false

    before_action :build_query, only: :create
    authorize_resource :query, only: :create

    def show
      render_result
    end

    def create
      render_result
    end

    private

    def render_result
      query_result = Queries::RunQuery.call(@query, variables_hash: variables_params.to_unsafe_h,
                                                    limit: params[:limit].presence,
                                                    filters: filter_params)

      if query_result.error
        render json: { errors: [{ detail: query_result.error }] }, status: :unprocessable_entity
      else
        render json: query_result_hash(query_result)
      end
    end

    def current_user_variables
      return {} unless current_user

      current_user
        .attributes
        .slice('id', 'email')
        .transform_keys { |key| "current_user_#{key}" }
        .compact
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

    def variables_params
      params.fetch(:variables, {}).merge(current_user_variables)
    end

    def filter_params
      (params[:filter] || params[:filters])&.to_unsafe_h
    end
  end
end
