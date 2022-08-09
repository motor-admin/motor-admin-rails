# frozen_string_literal: true

module Motor
  module ApiQuery
    module BuildMeta
      module_function

      def call(rel, params)
        meta = {}

        if params[:meta].to_s.include?('count')
          meta[:count] =
            rel.limit(nil).offset(nil).reorder(nil).select(rel.klass.arel_table[rel.klass.primary_key]).count
        end

        meta
      end
    end
  end
end
