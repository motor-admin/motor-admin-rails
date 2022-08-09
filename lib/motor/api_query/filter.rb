# frozen_string_literal: true

module Motor
  module ApiQuery
    module Filter
      LIKE_FILTER_VALUE_REGEXP = /\A%?(.*?)%?\z/.freeze
      DISTINCT_RESTRICTED_COLUMN_TYPES = %i[json point].freeze

      module_function

      def call(rel, params)
        return rel if params.blank?

        normalized_params = normalize_params(Array.wrap(params))

        rel = apply_filters(rel, normalized_params)
        rel = rel.distinct if can_apply_distinct?(rel)

        rel
      end

      def clean_filters(value)
        if value.class.name == 'ActionController::Parameters'
          value.to_unsafe_h
        elsif value.is_a?(Array)
          value.map { |v| clean_filters(v) }
        else
          value
        end
      end

      def apply_predicates(rel, filters)
        joins = ActiveRecord::PredicateBuilder.filter_joins(rel.klass, filters)

        joins.flatten.reduce(rel) do |acc, j|
          if j.is_a?(String) || j.is_a?(Arel::Nodes::Join)
            acc.joins(j)
          elsif j.present?
            acc.left_outer_joins(j)
          else
            acc
          end
        end
      end

      def apply_filters(rel, filters)
        filters = clean_filters(filters)

        rel = apply_predicates(rel, filters)

        alias_tracker = ActiveRecord::Associations::AliasTracker.create(rel.connection, rel.table.name, [])
        filter_clause_factory = ActiveRecord::Relation::FilterClauseFactory.new(rel.klass, rel.predicate_builder)

        where_clause = filter_clause_factory.build(filters, alias_tracker)

        rel_values = rel.instance_variable_get(:@values)

        if rel_values[:where]
          rel_values[:where] += where_clause
        else
          rel_values[:where] = where_clause
        end

        rel
      end

      def normalize_params(params)
        params.map do |item|
          next item if item.is_a?(String)
          next normalize_params(item) if item.is_a?(Array)

          item = item.to_unsafe_h if item.respond_to?(:to_unsafe_h)

          item.transform_values do |filter|
            if filter.is_a?(Hash)
              normalize_filter_hash(filter)
            else
              filter
            end
          end
        end.split('OR').product(['OR']).flatten(1)[0...-1]
      end

      def normalize_filter_hash(hash)
        hash.each_with_object({}) do |(action, value), acc|
          new_action, new_value =
            if value.is_a?(Hash)
              [action, normalize_filter_hash(value)]
            else
              normalize_action(action, value)
            end

          acc[new_action] = new_value

          acc
        end
      end

      def can_apply_distinct?(rel)
        rel.columns.none? do |column|
          DISTINCT_RESTRICTED_COLUMN_TYPES.include?(column.type)
        end
      end

      def normalize_action(action, value)
        case action
        when 'includes'
          ['contains', value]
        when 'contains'
          ['ilike', value.sub(LIKE_FILTER_VALUE_REGEXP, '%\1%')]
        when 'starts_with'
          ['ilike', value.sub(LIKE_FILTER_VALUE_REGEXP, '\1%')]
        when 'ends_with'
          ['ilike', value.sub(LIKE_FILTER_VALUE_REGEXP, '%\1')]
        when 'eqnull'
          ['eq', nil]
        when 'neqnull'
          ['neq', nil]
        else
          [action, value]
        end
      end
    end
  end
end
