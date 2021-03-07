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
