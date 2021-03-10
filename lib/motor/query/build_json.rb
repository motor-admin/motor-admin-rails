module Motor
  module Query
    module BuildJson
      module_function

      def call(rel, params)
        json_params = {}

        if (params[:include])
          include_params = params[:include].split(',')

          rel = rel.preload(include_params) if rel.is_a?(ActiveRecord::Relation)
          json_params[:include] = include_params
        end

        rel.as_json(json_params)
      end
    end
  end
end
