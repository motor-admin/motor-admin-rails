require_relative './query/sort'
require_relative './query/paginate'
require_relative './query/filter'
require_relative './query/build_meta'

module Motor
  module Query
    module_function

    def call(rel, params)
      rel = Query::Sort.call(rel, params)
      rel = Query::Paginate.call(rel, params)

      rel
    end
  end
end
