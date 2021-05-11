# frozen_string_literal: true

module Motor
  module ApiQuery
    module Filter
      LIKE_FILTER_VALUE_REGEXP = /\A%?(.*?)%?\z/.freeze

      module_function

      def call(rel, params)
        return rel if params.blank?

        normalized_params = normalize_params(Array.wrap(params))

        rel.filter(normalized_params).distinct
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

      def normalize_action(action, value)
        case action
        when 'contains'
          ['ilike', value.sub(LIKE_FILTER_VALUE_REGEXP, '%\1%')]
        when 'starts_with'
          ['ilike', value.sub(LIKE_FILTER_VALUE_REGEXP, '\1%')]
        when 'ends_with'
          ['ilike', value.sub(LIKE_FILTER_VALUE_REGEXP, '%\1')]
        else
          [action, value]
        end
      end
    end
  end
end
