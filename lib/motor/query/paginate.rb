module Motor
  module Query
    module Paginate
      MAX_PER_PAGE = 500

      module_function

      def call(rel, params)
        page_params = params[:page]

        return rel if page_params.blank?

        rel = rel.limit([MAX_PER_PAGE, page_params[:limit].to_i].min) if page_params[:limit].present?
        rel = rel.offset(page_params[:offset].to_i) if page_params[:offset].present?

        rel
      end
    end
  end
end
