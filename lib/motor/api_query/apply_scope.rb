# frozen_string_literal: true

module Motor
  module ApiQuery
    module ApplyScope
      module_function

      def call(rel, scope)
        return rel if scope.blank?

        scope_symbol = scope.to_sym

        if rel.klass.defined_scopes.include?(scope_symbol)
          rel.public_send(scope_symbol)
        else
          apply_filter_scope(rel, scope)
        end
      end

      def apply_filter_scope(rel, scope)
        configs = Motor::Resource.find_by_name(rel.klass.name.underscore)

        return rel unless configs

        scope_configs = configs.preferences[:scopes].find { |s| s[:name] == scope }

        return rel unless scope_configs

        ApiQuery::Filter.call(rel, scope_configs[:preferences][:filter])
      end
    end
  end
end
