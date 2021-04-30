# frozen_string_literal: true

module Motor
  module ApiQuery
    module BuildJson
      module_function

      def call(rel, params)
        rel = rel.none if params.dig(:page, :limit).yield_self { |limit| limit.present? && limit.to_i.zero? }

        rel = rel.preload_associations_lazily if rel.is_a?(ActiveRecord::Relation)

        json_params = {}

        assign_include_params(json_params, rel, params)
        assign_fields_params(json_params, rel, params)

        rel.as_json(json_params.with_indifferent_access)
      end

      def assign_include_params(json_params, _rel, api_params)
        return if api_params['include'].blank?

        include_params = api_params['include']

        if include_params.is_a?(String)
          include_params =
            include_params.split(',').reduce({}) do |accumulator, path|
              hash = {}

              path.split('.').reduce(hash) do |acc, part|
                acc[part] = {}

                acc[part]
              end

              accumulator.deep_merge(hash)
            end
        end

        json_params.deep_merge!(normalize_include_params(include_params))
      end

      def assign_fields_params(json_params, rel, params)
        return if params[:fields].blank?

        model = rel.is_a?(ActiveRecord::Relation) ? rel.klass : rel.class
        model_name = model.name.underscore

        params[:fields].each do |key, fields|
          fields = fields.split(',') if fields.is_a?(String)

          if key == model_name || model_name.split('/').last == key
            json_params.merge!(build_fields_hash(model, fields))
          else
            hash = find_key_in_params(json_params, key)

            fields_hash = build_fields_hash(model.reflections[key]&.klass, fields)

            hash.merge!(fields_hash)
          end
        end
      end

      def build_fields_hash(model, fields)
        columns = model ? model.columns.map(&:name) : []
        fields_hash = { 'only' => [], 'methods' => [] }

        fields.each_with_object(fields_hash) do |field, acc|
          if field.in?(columns)
            acc['only'] << field
          elsif model.nil? || model.instance_methods.include?(field.to_sym)
            acc['methods'] << field
          end
        end
      end

      def find_key_in_params(params, key)
        params = params['include']

        return if params.blank?
        return params[key] if params[key]

        params.keys.reduce(nil) do |acc, k|
          acc || find_key_in_params(params[k], key)
        end
      end

      def normalize_include_params(params)
        case params
        when Array
          params.each_with_object({}) do |name, hash|
            hash[name] = { 'include' => {} }
          end
        when String
          { params => { 'include' => {} } }
        when Hash
          include_hash =
            params.transform_values do |value|
              normalize_include_params(value)
            end

          { 'include' => include_hash }
        else
          raise ArgumentError, "Wrong include param type #{params.class}"
        end
      end
    end
  end
end
