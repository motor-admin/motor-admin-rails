# frozen_string_literal: true

module Motor
  class ApiConfig < ::Motor::ApplicationRecord
    encrypts :credentials if defined?(::Motor::EncryptedConfig)

    attribute :preferences, default: -> { ActiveSupport::HashWithIndifferentAccess.new }
    attribute :credentials, default: -> { ActiveSupport::HashWithIndifferentAccess.new }

    serialize :credentials, Motor::HashSerializer

    if Rails.version.to_f >= 7.1
      serialize :preferences, coder: Motor::HashSerializer
    else
      serialize :preferences, Motor::HashSerializer
    end

    has_one :form, dependent: nil, foreign_key: :api_config_name, primary_key: :name, inverse_of: :api_config

    scope :active, -> { where(deleted_at: nil) }

    def headers
      credentials.fetch(:headers, []).each_with_object({}) do |item, acc|
        acc[item[:key]] = item[:value]
      end
    end
  end
end
