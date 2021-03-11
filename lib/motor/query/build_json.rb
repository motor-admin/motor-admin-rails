# frozen_string_literal: true

module Motor
  module Query
    module BuildJson
      module_function

      def call(rel, params)
        json_params = {}

        if params[:include]
          include_params = params[:include].split(',')

          json_params[:include] = include_params
        end

        rel.as_json(json_params)
      end
    end
  end
end
