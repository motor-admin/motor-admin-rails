# frozen_string_literal: true

module Motor
  module Query
    module BuildMeta
      module_function

      def call(rel, params)
        meta = {}

        meta[:count] = rel.limit(nil).offset(nil).reorder(nil).count if params[:meta].to_s.include?('count')

        meta
      end
    end
  end
end
