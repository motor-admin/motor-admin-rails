# frozen_string_literal: true

module Motor
  module ApiQuery
    module Paginate
      MAX_PER_PAGE = 500

      module_function

      def call(rel, params)
        params ||= {}

        rel = rel.limit([MAX_PER_PAGE, (params[:limit] || MAX_PER_PAGE).to_i].min)

        rel.offset(params[:offset].to_i)
      end
    end
  end
end
