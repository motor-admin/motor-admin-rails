# frozen_string_literal: true

module Motor
  module Resources
    module FetchConfiguredModel
      CACHE_HASH = ActiveSupport::HashWithIndifferentAccess.new

      HAS_AND_BELONGS_TO_MANY_JOIN_MODEL_PREFIX = 'HABTM_'

      module_function

      def call(model, cache_key:)
        configs = Motor::Configs::LoadFromCache.load_resources(cache_key: cache_key)

        return model if model.name == 'ActiveStorage::Attachment'
        return model if sti_model?(model)

        maybe_fetch_from_cache(
          model,
          cache_key.to_s + model.object_id.to_s,
          -> { build_configured_model_from_configs(model, configs) },
          ->(klass) { configure_reflection_classes(klass, cache_key) }
        )
      end

      def build_configured_model(model, config)
        klass = Class.new(model)
        klass.inheritance_column = nil if model.superclass.abstract_class

        define_class_properties(klass, model)

        define_columns_hash(klass, config)
        define_default_scope(klass, config)
        define_column_reflections(klass, config)
        define_associations(klass, config)
        define_searchable_columns_method(klass, config)

        klass
      end

      def define_default_scope(klass, config)
        return klass if config[:custom_sql].blank?

        klass.instance_variable_set(:@__motor_custom_sql, config[:custom_sql].squish.delete_suffix(';'))

        klass.instance_eval do
          default_scope do
            from(Arel.sql("(#{self.klass.instance_variable_get(:@__motor_custom_sql)})")
                     .as(connection.quote_column_name(table_name)))
          end
        end

        klass
      end

      def define_audited_class(klass)
        default_audit_class = Audited.audit_class

        Audited.audit_class = 'Motor::Audit'

        klass.audited

        klass
      ensure
        Audited.audit_class = default_audit_class
      end

      def define_class_properties(klass, model)
        define_audited_class(klass) unless [Audited::Audit, Motor::Audit].include?(model)

        klass.table_name = model.table_name

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

      def define_searchable_columns_method(klass, config)
        return if config[:searchable_columns].blank?

        klass.instance_variable_set(:@__motor_searchable_columns, config[:searchable_columns])

        klass.instance_eval do
          def motor_searchable_columns
            @__motor_searchable_columns
          end
        end
      end

      def define_columns_hash(klass, config)
        return klass if config[:custom_sql].blank?

        columns = Resources::CustomSqlColumnsCache.call(config[:custom_sql])

        columns_hash =
          columns.each_with_object({}) do |column, acc|
            acc[column[:name]] =
              ActiveRecord::ConnectionAdapters::Column.new(
                column[:name],
                nil,
                ActiveRecord::ConnectionAdapters::SqlTypeMetadata.new(sql_type: column[:column_type],
                                                                      type: column[:column_type].to_sym)
              )
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
        if config[:model_name] == 'active_storage/attachment'
          klass.has_one_attached(config[:name].delete_suffix('_attachment').to_sym)
        else
          options = {
            **klass.reflections[config[:name]]&.options.to_h,
            class_name: config[:model_name].classify,
            foreign_key: config[:foreign_key],
            primary_key: config[:primary_key],
            **config[:options].to_h
          }.symbolize_keys

          klass.has_one(config[:name].to_sym, **options)
        end
      end

      def configure_reflection_classes(klass, cache_key)
        klass._reflections.each do |key, ref|
          next unless configure_reflection_class?(ref)

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

          define_association(klass, association[:name], options, filters)
        end
      end

      def define_association(klass, name, options, filters)
        if options[:class_name] == 'ActiveStorage::Attachment'
          klass.has_many_attached name.delete_suffix('_attachments').to_sym
        elsif filters.present?
          klass.has_many(name.to_sym, lambda {
                                        Motor::ApiQuery::Filter.apply_filters(all, filters).distinct
                                      }, **options.symbolize_keys)
        else
          klass.has_many(name.to_sym, **options.symbolize_keys)
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

      def build_configured_model_from_configs(model, configs)
        resource_config = configs.find { |r| r.name == model.name.underscore }

        if resource_config
          build_configured_model(model, resource_config.preferences)
        else
          define_class_properties(Class.new(model), model)
        end
      end

      def configure_reflection_class?(ref)
        begin
          return false unless ref.klass
        rescue StandardError
          return false
        end

        return false if ref.klass.anonymous?
        return false if ref.klass.name.demodulize.starts_with?(HAS_AND_BELONGS_TO_MANY_JOIN_MODEL_PREFIX)

        true
      end

      def sti_model?(model)
        !model.superclass.abstract_class && model.columns_hash[model.inheritance_column.to_s]
      end
    end
  end
end
