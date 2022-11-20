# frozen_string_literal: true

module Motor
  module Alerts
    module SlackSender
      MARKDOWN_LINK_TRANSFORM_REGEXP = /\[(.+?)\]\((.+?)\)/.freeze
      MARKDOWN_PATHS_TRANSFORM_REGEXP = /\n\s*\#{1,5}\s*(.*)\n?/.freeze
      MARKDOWN_HEADING_TRANSFORM_REGEXP = /\n\s*\#{1,5}\s*(.*)\n?/.freeze
      MARKDOWN_BOLD_TRANSFORM_REGEXP = /[*_]{2}/.freeze

      DEFAULT_FILENAME = 'data.csv'

      module_function

      def call(alert, conversation_id, slack_user: nil)
        query_result = load_data(alert, slack_user)

        if alert.query.preferences[:visualization] == 'markdown'
          text = [build_query_link(alert), render_markdown(alert, query_result)].join

          Slack::Client.send_message(channel: conversation_id,
                                     as_user: slack_user.present?,
                                     text: text)
        else
          Slack::Client.send_message(channel: conversation_id,
                                     as_user: slack_user.present?,
                                     text: build_alert_message(alert))
          Slack::Client.send_file(channels: conversation_id,
                                  content: generate_csv(query_result),
                                  filename: DEFAULT_FILENAME)
        end
      end

      def build_alert_message(alert)
        <<~MARKDOWN
          #{build_query_link(alert)}
          #{alert.description}
        MARKDOWN
      end

      def build_query_link(alert)
        link = Motor::Admin.routes.url_helpers.motor_ui_query_url(alert.query_id, host: Motor.app_host)

        "*<#{link}|#{alert.name}>*"
      end

      def render_markdown(alert, query_result)
        params = query_result.columns.pluck(:name).zip(query_result.data[0]).to_h.symbolize_keys

        markdown =
          ["\n", Mustache.render(alert.query.preferences[:visualization_options][:markdown], **params)].join

        markdown.gsub(/\((.*)\)/, "(http://#{Motor.app_host}\\1)")
                .gsub(MARKDOWN_LINK_TRANSFORM_REGEXP, '<\2|\1>')
                .gsub(MARKDOWN_HEADING_TRANSFORM_REGEXP, "\n\n*\\1*")
                .gsub(MARKDOWN_BOLD_TRANSFORM_REGEXP, '*')
      end

      def generate_csv(query_result)
        rows = [query_result.columns.pluck(:name)] + query_result.data

        rows.map(&:to_csv).join
      end

      def load_data(alert, slack_user = nil)
        if slack_user
          Queries::RunQuery.call(alert.query, variables_hash: { current_user_email: slack_user['email'] })
        else
          Queries::RunQuery.call(alert.query)
        end
      end
    end
  end
end
