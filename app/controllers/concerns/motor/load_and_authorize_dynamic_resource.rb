# frozen_string_literal: true

module Motor
  module LoadAndAuthorizeDynamicResource
    extend ActiveSupport::Concern

    MUTEX = Mutex.new

    INSTANCE_VARIABLE_NAME = 'resource'
    ASSOCIATION_INSTANCE_VARIABLE_NAME = 'associated_resource'

    included do
      before_action :load_and_authorize_resource
      before_action :load_and_authorize_association
    end

    def resource_class
      @resource_class ||= MUTEX.synchronize do
        Motor::Resources::FetchConfiguredModel.call(
          Motor::BuildSchema::Utils.classify_slug(resource_name_prefix + params[:resource]),
          cache_key: Motor::Resource.maximum(:updated_at)
        )
      end
    end

    def resource_name_prefix
      ''
    end

    def load_and_authorize_resource
      options = {
        class: resource_class,
        parent: params[:association].present?,
        instance_name: INSTANCE_VARIABLE_NAME
      }

      if params[:resource_id].present?
        options = options.merge(
          parent: true,
          id_param: :resource_id
        )
      end

      preload_composite_primary_key_resource(resource_class, options[:id_param] || :id, INSTANCE_VARIABLE_NAME)

      CanCan::ControllerResource.new(
        self,
        options
      ).load_and_authorize_resource
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    def load_and_authorize_association
      return if params[:association].blank?

      association = resource_class.reflections[params[:association]]

      if association
        instance_name = params[:action] == 'create' ? ASSOCIATION_INSTANCE_VARIABLE_NAME : INSTANCE_VARIABLE_NAME

        preload_composite_primary_key_resource(
          association.klass, :id, instance_name,
          scope: @resource&.public_send(params[:association])
        )

        CanCan::ControllerResource.new(
          self,
          class: association.klass,
          parent: false,
          through: :resource,
          through_association: params[:association].to_sym,
          instance_name: instance_name
        ).load_and_authorize_resource
      else
        render json: { message: 'Unknown association' }, status: :not_found
      end
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    def preload_composite_primary_key_resource(model, id_param_key, instance_name, scope: nil)
      return unless model.respond_to?(:primary_key) && model.primary_key.is_a?(Array)
      return if instance_variable_defined?("@#{instance_name}") && instance_variable_get("@#{instance_name}")

      raw_id = params[id_param_key]

      return if raw_id.blank?

      separator = model.param_delimiter
      pk_values = raw_id.to_s.split(separator)

      return unless pk_values.size == model.primary_key.size

      record = (scope || model).find_by(model.primary_key.zip(pk_values).to_h)

      raise ActiveRecord::RecordNotFound unless record

      instance_variable_set("@#{instance_name}", record)
    end
  end
end
