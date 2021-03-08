module Motor
  module Query
    module BuildMeta
      module_function

      def call(rel, params)
        meta = {}

        if params[:meta].to_s.include?('count')
          meta[:count] = rel.limit(nil).offset(nil).reorder(nil).count
        end

        meta
      end
    end
  end
end
