# frozen_string_literal: true

module Motor
  class ApiConfig < ::Motor::ApplicationRecord
    encrypts :credentials if defined?(::Motor::EncryptedConfig)

    serialize :credentials, Motor::HashSerializer
    serialize :preferences, Motor::HashSerializer

    attribute :preferences, default: -> { HashWithIndifferentAccess.new }
    attribute :credentials, default: -> { HashWithIndifferentAccess.new }

    has_one :form, dependent: nil, foreign_key: :api_config_name, primary_key: :name, inverse_of: :api_config

    scope :active, -> { where(deleted_at: nil) }

    def headers
      credentials.fetch(:headers, []).each_with_object({}) do |item, acc|
        acc[item[:key]] = item[:value]
      end
    end
  end
end
