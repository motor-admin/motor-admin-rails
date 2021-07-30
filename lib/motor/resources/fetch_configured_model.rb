# frozen_string_literal: true

module Motor
  module Resources
    module FetchConfiguredModel
      CACHE_HASH = HashWithIndifferentAccess.new

      module_function

      def call(model, cache_key:)
        configs = Motor::Configs::LoadFromCache.load_resources(cache_key: cache_key)

        return model if configs.blank?

        maybe_fetch_from_cache(
          model,
          cache_key,
          lambda {
            resource_config = configs.find { |r| r.name == model.name.underscore }

            if resource_config
              build_configured_model(model, resource_config.preferences)
            else
              define_class_name_method(Class.new(model), model)
            end
          },
          ->(klass) { configure_reflection_classes(klass, cache_key) }
        )
      end

      def build_configured_model(model, config)
        klass = Class.new(model)

        define_class_name_method(klass, model)

        define_columns_hash(klass, config)
        define_default_scope(klass, config)
        define_column_reflections(klass, config)
        define_associations(klass, config)

        klass
      end

      def define_default_scope(klass, config)
        return klass if config[:custom_sql].blank?

        klass.instance_variable_set(:@__motor_custom_sql, config[:custom_sql].squish)

        klass.instance_eval do
          default_scope do
            from(Arel.sql("(#{self.klass.instance_variable_get(:@__motor_custom_sql)})").as(table_name))
          end
        end

        klass
      end

      def define_class_name_method(klass, model)
        klass.instance_variable_set(:@__motor_model_name, model.name)

        klass.instance_eval do
          def name
            @__motor_model_name
          end

          def inspect
            super.gsub(/\#<Class:0x\w+>/, name)
          end

          def to_s
            super.gsub(/\#<Class:0x\w+>/, name)
          end

          def anonymous?
            true
          end
        end

        klass
      end

      def define_columns_hash(klass, config)
        return klass if config[:custom_sql].blank?

        columns = Resources::CustomSqlColumnsCache.call(config[:custom_sql])

        columns_hash =
          columns.each_with_object({}) do |column, acc|
            acc[column[:name]] = ActiveRecord::ConnectionAdapters::Column.new(column[:name], nil)
          end

        klass.instance_variable_set(:@__motor_custom_sql_columns_hash, columns_hash)

        # rubocop:disable Naming/MemoizedInstanceVariableName
        klass.instance_eval do
          def columns_hash
            @__motor__columns_hash ||= @__motor_custom_sql_columns_hash.merge(super)
          end
        end
        # rubocop:enable Naming/MemoizedInstanceVariableName
      end

      def define_column_reflections(klass, config)
        config.fetch(:columns, []).each do |column|
          reference = column[:reference]

          next if reference.blank?
          next unless reference[:virtual]

          if reference[:reference_type] == 'belongs_to'
            define_belongs_to_reflection(klass, reference)
          else
            define_has_one_reflection(klass, reference)
          end
        end
      end

      def define_belongs_to_reflection(klass, config)
        klass.belongs_to(config[:name].to_sym,
                         class_name: config[:model_name]&.classify,
                         foreign_key: config[:foreign_key],
                         polymorphic: config[:polymorphic],
                         primary_key: config[:primary_key],
                         optional: true)
      end

      def define_has_one_reflection(klass, config)
        options = {
          class_name: config[:model_name].classify,
          foreign_key: config[:foreign_key],
          primary_key: config[:primary_key]
        }

        options = options.merge(config[:options] || {})

        klass.has_one(config[:name].to_sym, **options.symbolize_keys)
      end

      def configure_reflection_classes(klass, cache_key)
        klass.reflections.each do |key, ref|
          begin
            next unless ref.klass
            next if ref.klass.anonymous?
          rescue StandardError
            next
          end

          ref_dup = ref.dup

          if ref.klass.name == klass.name
            ref_dup.instance_variable_set(:@klass, klass)
          else
            ref_dup.instance_variable_set(:@klass, call(ref.klass, cache_key: cache_key))
          end

          klass.reflections[key] = ref_dup
        end

        klass._reflections = klass.reflections

        klass
      end

      def define_associations(klass, config)
        config.fetch(:associations, []).each do |association|
          next unless association[:virtual]

          options = normalize_association_params(association)

          filters = options.delete(:filters)

          if filters.present?
            klass.has_many(association[:name].to_sym, -> { filter(filters).tap(&:arel) }, **options.symbolize_keys)
          else
            klass.has_many(association[:name].to_sym, **options.symbolize_keys)
          end
        end
      end

      def normalize_association_params(params)
        options = params.slice(:foreign_key, :primary_key).merge(dependent: :destroy)

        options[:class_name] = params[:model_name].classify
        options[:as] = params[:foreign_key].delete_suffix('_id') if params[:polymorphic]

        options.merge(params[:options] || {})
      end

      def maybe_fetch_from_cache(model, cache_key, miss_cache_block, postprocess_block)
        return miss_cache_block.call unless cache_key

        if CACHE_HASH[model.name] && CACHE_HASH[model.name][:key] == cache_key
          CACHE_HASH[model.name][:value]
        else
          result = miss_cache_block.call

          CACHE_HASH[model.name] = { key: cache_key, value: result }

          postprocess_block.call(result)
        end
      end
    end
  end
end
