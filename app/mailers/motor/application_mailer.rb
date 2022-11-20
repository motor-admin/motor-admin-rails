# frozen_string_literal: true

module Motor
  class ApplicationMailer < ActionMailer::Base
    layout 'motor/mailer'

    private

    def from_address
      from = ENV['MOTOR_ALERTS_FROM_ADDRESS'].presence || ENV['MOTOR_EMAIL_ADDRESS'].presence

      from ||= application_mailer_default_from
      from ||= mailer_config_from_address
      from ||= "reports@#{ENV['HOST'].delete_prefix('www.')}" if ENV['HOST'].present?

      from ||= 'reports@example.com' if Rails.env.development?

      from
    end

    def application_mailer_default_from
      return if !defined?(::ApplicationMailer) || ::ApplicationMailer.default[:from].to_s.include?('example.com')

      ::ApplicationMailer.default[:from].presence
    end

    def mailer_config_from_address
      return if Rails.application.config.action_mailer.default_url_options&.dig(:host).blank?

      "reports@#{Rails.application.config.action_mailer.default_url_options[:host].delete_prefix('www.')}"
    end
  end
end
