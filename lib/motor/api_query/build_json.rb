# frozen_string_literal: true

module Motor
  module ApiQuery
    module BuildJson
      module_function

      # @param rel [ActiveRecord::Base, ActiveRecord::Relation]
      # @param params [Hash]
      # @param current_ability [CanCan::Ability]
      # @return [Hash]
      def call(rel, params, current_ability = Motor::CancanUtils::CanManageAll.new)
        rel = rel.none if limit_zero_params?(params)
        rel = rel.preload_associations_lazily if rel.is_a?(ActiveRecord::Relation)

        model = rel.is_a?(ActiveRecord::Relation) ? rel.klass : rel.class

        include_hash = build_include_hash(params['include'])
        models_index = build_models_index(model, include_hash)

        json_params = normalize_include_params(include_hash)

        assign_fields_params!(json_params, model, params, current_ability, models_index)

        rel.as_json(json_params.with_indifferent_access)
      end

      # @param include_params [Hash]
      # @return [Hash]
      def build_include_hash(include_params)
        return {} if include_params.blank?

        if include_params.is_a?(String)
          build_hash_from_string_path(include_params)
        else
          include_params
        end
      end

      # @param json_params [Hash]
      # @param model [Class<ActiveRecord::Base>]
      # @param params [Hash]
      # @param current_ability [CanCan::Ability]
      # @param models_index [Hash]
      # @return [void]
      def assign_fields_params!(json_params, model, params, current_ability, models_index)
        return if params[:fields].blank?

        params[:fields].each do |key, fields|
          fields_model = models_index[key]

          next unless model

          fields = fields.split(',') if fields.is_a?(String)

          fields_hash = fields_model == model ? json_params : find_key_in_params(json_params, key)

          fields_hash.merge!(build_fields_hash(fields_model, fields, current_ability))
        end
      end

      # @param model [Class<ActiveRecord::Base>]
      # @param fields [Hash]
      # @param current_ability [CanCan::Ability]
      # @return [Hash]
      def build_fields_hash(model, fields, current_ability)
        return { 'methods' => fields } unless model

        column_names = model.column_names.map(&:to_sym)
        instance_methods = model.instance_methods
        permitted_attributes = current_ability.permitted_attributes(:read, model)
        is_permitted_all = column_names == permitted_attributes

        fields_hash = { 'only' => [], 'methods' => [] }

        fields.each_with_object(fields_hash) do |field, acc|
          field_symbol = field.to_sym

          next if !is_permitted_all && permitted_attributes.exclude?(field_symbol)

          if model.columns_hash[field]
            acc['only'] << field
          elsif instance_methods.include?(field_symbol)
            acc['methods'] << field
          end
        end
      end

      # @param params [Hash]
      # @param key [String]
      # @return [Hash]
      def find_key_in_params(params, key)
        params = params['include']

        return {} if params.blank?
        return params[key] if params[key]

        params.keys.reduce(nil) do |acc, k|
          acc || find_key_in_params(params[k], key)
        end
      end

      # @param params [Hash]
      # @return [Hash]
      def normalize_include_params(params)
        case params
        when Array
          params.index_with do |_|
            { 'include' => {} }
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

      # @param model [Class<ActiveRecord::Base>]
      # @param includes_hash [Hash]
      # @return [Hash]
      def build_models_index(model, includes_hash)
        default_index = {
          model.name.underscore => model,
          model.name.underscore.split('/').last => model
        }

        includes_hash.reduce(default_index) do |acc, (key, value)|
          reflection = model.reflections[key]

          next acc unless reflection
          next acc if reflection.polymorphic?

          acc[key] = reflection.klass

          acc.merge(build_models_index(reflection.klass, value))
        end
      end

      # @param string_path [String]
      # @return [Hash]
      def build_hash_from_string_path(string_path)
        string_path.split(',').reduce({}) do |accumulator, path|
          hash = {}

          path.split('.').reduce(hash) do |acc, part|
            acc_hash = {}

            acc[part] = acc_hash

            acc_hash
          end

          accumulator.deep_merge(hash)
        end
      end

      # @param params [Hash]
      # @return [Boolean]
      def limit_zero_params?(params)
        params.dig(:page, :limit).then { |limit| limit.present? && limit.to_i.zero? }
      end
    end
  end
end
