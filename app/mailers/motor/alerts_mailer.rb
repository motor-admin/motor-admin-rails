# frozen_string_literal: true

module Motor
  class AlertsMailer < ApplicationMailer
    SenderAddressNotSet = Class.new(StandardError)
    SENDER_NOT_SET_ERROR_MESSAGE =
      'Please specify your sender address via MOTOR_ALERTS_FROM_ADDRESS environment variable'

    def alert_email(alert, email: nil)
      @alert = alert
      @query_result = Queries::RunQuery.call(alert.query,
                                             variables_hash: { current_user_email: email })

      return if @alert.preferences[:send_empty].blank? && @query_result.data.blank?

      assign_attachment(@alert, @query_result)

      raise SenderAddressNotSet, SENDER_NOT_SET_ERROR_MESSAGE unless from_address

      mail(
        from: from_address,
        to: email || alert.to_emails,
        subject: alert.name.presence || @alert.query.name
      )
    end

    private

    def assign_attachment(alert, query_result)
      attachments["#{alert.name.presence || 'data'}.csv"] = generate_csv(query_result)
    end

    def generate_csv(query_result)
      rows = [query_result.columns.pluck(:name)] + query_result.data

      rows.map(&:to_csv).join
    end
  end
end
