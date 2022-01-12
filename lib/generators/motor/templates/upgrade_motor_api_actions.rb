class <%= migration_class_name %> < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  class MotorApiConfig < ActiveRecord::Base
    self.table_name = 'motor_api_configs'

    encrypts :credentials if defined?(::Motor::EncryptedConfig)

    serialize :credentials, Motor::HashSerializer
    serialize :preferences, Motor::HashSerializer

    attribute :preferences, default: -> { HashWithIndifferentAccess.new }
    attribute :credentials, default: -> { HashWithIndifferentAccess.new }
  end

  class MotorForm < ActiveRecord::Base
    self.table_name = 'motor_forms'

    serialize :preferences, Motor::HashSerializer
  end

  class MotorResource < ActiveRecord::Base
    self.table_name = 'motor_resources'

    serialize :preferences, Motor::HashSerializer
  end

  def up
    MotorResource.all.each do |resource|
      resource.preferences.fetch(:actions, []).each do |action|
        next unless action[:action_type] == 'api'

        api_path = action[:preferences][:api_path]
        api_url = api_path[%r{\Ahttps?://[^/]+}]
        api_path = api_path.delete_prefix(api_url).sub(/\A\/?/, '/') if api_url

        api_config =
          if api_url
            MotorApiConfig.create_with(url: api_url).find_or_create_by!(name: api_url.sub(%r{\Ahttps?://}))
          else
            MotorApiConfig.create_with(url: '/').find_or_create_by!(name: 'origin')
          end

        resource_display_name = (resource[:preferences][:display_name] || resource.name).titleize.singularize

        form = MotorForm.create_with(
          api_config_name: api_config.name,
          api_path: api_path.sub(/\{{1,2}\w+\}{1,2}/, '{{id}}'),
          http_method: 'POST',
          preferences: {
            fields: [{
              name: 'id',
              display_name: resource_display_name,
              default_value: '',
              field_type: 'reference',
              reference: { model_name: resource.name },
              validators: [{ required: true }]
            }]
          }
        ).find_or_create_by!(
          name: "#{action[:display_name]} #{resource_display_name}"
        )

        action[:action_type] = 'form'
        action[:preferences] = { form_id: form.id }
      end

      resource.save!
    end
  end

  def down; end
end
