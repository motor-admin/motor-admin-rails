# frozen_string_literal: true

module Motor
  class AlertsMailer < ApplicationMailer
    def alert_email(alert)
      @alert = alert
      @query_result = Queries::RunQuery.call(alert.query)

      return if @alert.preferences[:send_empty].blank? && @query_result.data.blank?

      attachments["#{alert.name.presence || 'data'}.csv"] = generate_csv(@query_result)

      mail(
        from: from_address,
        to: alert.to_emails,
        subject: alert.name.presence || @alert.query.name
      )
    end

    private

    def generate_csv(_query_result)
      rows = [@query_result.columns.pluck(:name)] + @query_result.data

      rows.map(&:to_csv).join
    end

    def from_address
      from = ENV['MOTOR_ADMIN_FROM_ADDRESS'].presence

      from ||= application_mailer_default_from
      from ||= mailer_config_from_address
      from ||= "reports@#{ENV['HOST']}" if ENV['HOST'].present?

      from
    end

    def application_mailer_default_from
      return if !defined?(ApplicationMailer) || ApplicationMailer.default[:from] == 'from@example.com'

      ApplicationMailer.default[:from]
    end

    def mailer_config_from_address
      return if Rails.application.config.action_mailer.default_url_options[:host].blank?

      "reports@#{Rails.application.config.action_mailer.default_url_options[:host]}"
    end
  end
end