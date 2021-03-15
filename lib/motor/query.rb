# frozen_string_literal: true

require_relative './query/sort'
require_relative './query/paginate'
require_relative './query/filter'
require_relative './query/search'
require_relative './query/build_meta'
require_relative './query/build_json'

module Motor
  module Query
    module_function

    def call(rel, params)
      rel = Query::Sort.call(rel, params[:sort])
      rel = Query::Paginate.call(rel, params[:page])
      rel = Query::Filter.call(rel, params[:filter])
      rel = Query::Search.call(rel, params[:q] || params[:search] || params[:query])

      rel.preload_associations_lazily
    end
  end
end
