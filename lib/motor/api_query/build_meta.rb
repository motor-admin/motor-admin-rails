# frozen_string_literal: true

module Motor
  module ApiQuery
    module BuildMeta
      module_function

      def call(rel, params)
        meta = {}

        if params[:meta].to_s.include?('count')
          meta[:count] = rel.limit(nil).offset(nil).reorder(nil).count(:all)
        end

        meta
      end
    end
  end
end
