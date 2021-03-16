# frozen_string_literal: true

require_relative './api_query/sort'
require_relative './api_query/paginate'
require_relative './api_query/filter'
require_relative './api_query/search'
require_relative './api_query/build_meta'
require_relative './api_query/build_json'

module Motor
  module ApiQuery
    module_function

    def call(rel, params)
      rel = ApiQuery::Sort.call(rel, params[:sort])
      rel = ApiQuery::Paginate.call(rel, params[:page])
      rel = ApiQuery::Filter.call(rel, params[:filter])
      rel = ApiQuery::Search.call(rel, params[:q] || params[:search] || params[:query])

      rel.preload_associations_lazily
    end
  end
end
