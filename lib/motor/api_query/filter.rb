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
          acc[action] =
            if value.is_a?(Hash)
              normalize_filter_hash(value)
            else
              normalize_action_value(action, value)
            end
        end
      end

      def normalize_action_value(action, value)
        if %w[like ilike].include?(action)
          value.sub(LIKE_FILTER_VALUE_REGEXP, '%\1%')
        else
          value
        end
      end
    end
  end
end
