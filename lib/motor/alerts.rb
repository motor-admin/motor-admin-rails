# frozen_string_literal: true

module Motor
  module Alerts
    module_function

    def send_alert(alert)
      if alert.preferences[:adapter] == 'slack'
        send_slack_alert(alert)
      else
        send_email_alert(alert)
      end
    end

    def send_email_alert(alert)
      alert.to_emails.split(',').each do |email|
        if email.include?('@')
          Motor::AlertsMailer.alert_email(alert, email: email).deliver_now!
        else
          send_query_email_alerts(alert, email.gsub(/[{}]/, ''))
        end
      end
    end

    def send_query_email_alerts(alert, column_name)
      result = Queries::RunQuery.call(alert.query)

      column_index = result.columns.find_index { |c| c[:name] == column_name }

      emails = result.data.pluck(column_index).uniq

      emails.each do |email|
        Motor::AlertsMailer.alert_email(alert, email: email).deliver_now!
      end
    end

    def send_slack_alert(alert)
      slack_users = Slack::Client.load_users(limit: Slack::ITEMS_LIMIT)['members']

      alert.preferences[:slack_conversation_ids].each do |conversation_id|
        user = slack_users.find { |u| u['id'] == conversation_id }

        Motor::Alerts::SlackSender.call(alert, conversation_id, slack_user: user)
      end
    end
  end
end

require_relative './alerts/scheduler'
require_relative './alerts/scheduled_alerts_cache'
require_relative './alerts/persistance'
require_relative './alerts/slack_sender'
