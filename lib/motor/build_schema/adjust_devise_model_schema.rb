# frozen_string_literal: true

module Motor
  module BuildSchema
    module AdjustDeviseModelSchema
      HIDDEN_COLUMNS = %w[
        encrypted_password
        reset_password_token
        confirmation_token
      ].freeze

      READ_ONLY_COLUMNS = %w[
        reset_password_sent_at
        remember_created_at
        sign_in_count
        current_sign_in_at
        last_sign_in_at
        current_sign_in_ip
        last_sign_in_ip
        confirmed_at
        confirmation_sent_at
      ].freeze

      module_function

      def call(schema, devise_modules)
        modify_column_access_types!(schema[:columns])
        add_password_column!(schema[:columns]) if devise_modules.include?(:database_authenticatable)

        schema
      end

      def modify_column_access_types!(columns)
        columns.each do |column|
          column[:access_type] =
            case column[:name]
            when *HIDDEN_COLUMNS
              ColumnAccessTypes::HIDDEN
            when *READ_ONLY_COLUMNS
              ColumnAccessTypes::READ_ONLY
            else
              column[:access_type]
            end
        end
      end

      def add_password_column!(columns)
        columns << {
          name: 'password',
          display_name: I18n.t('motor.password'),
          column_type: 'string',
          access_type: 'write_only',
          default_value: nil,
          validators: [],
          virtual: true
        }
      end
    end
  end
end
