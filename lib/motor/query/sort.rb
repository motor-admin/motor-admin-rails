# frozen_string_literal: true

module Motor
  module Query
    module Sort
      FIELD_PARSE_REGEXP = /\A(-)?(.*)\z/.freeze

      module_function

      def call(rel, params)
        return rel if params.blank?

        normalized_params = build_params(params)

        rel.order(normalized_params)
      end

      def build_params(param)
        param.split(',').each_with_object({}) do |field, hash|
          direction, name = field.match(FIELD_PARSE_REGEXP).captures

          hash[name] = direction.present? ? :desc : :asc
        end
      end
    end
  end
end
