module Motor
  module Query
    module Paginate
      MAX_PER_PAGE = 500

      module_function

      def call(rel, params)
        page_params = params.fetch(:page, {})

        rel = rel.limit([MAX_PER_PAGE, (page_params[:limit] || MAX_PER_PAGE).to_i].min)
        rel = rel.offset(page_params[:offset].to_i)

        rel
      end
    end
  end
end
