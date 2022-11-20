# frozen_string_literal: true

module Motor
  module Slack
    module Client
      BASE_API_URL = 'https://slack.com/api'
      POST_MESSAGE_ENPOINT = "#{BASE_API_URL}/chat.postMessage"
      LOAD_CONVERSATIONS_ENPOINT = "#{BASE_API_URL}/conversations.list"
      LOAD_USERS_ENPOINT = "#{BASE_API_URL}/users.list"
      SEND_FILE_ENPOINT = "#{BASE_API_URL}/files.upload"

      ApiError = Class.new(StandardError)

      module_function

      def send_message(params = {})
        resp = Motor::NetHttpUtils.post(POST_MESSAGE_ENPOINT, params.merge(token: auth_token))

        parse_json_response_or_throw_error(resp)
      end

      def send_file(params = {})
        content = params.delete(:content)
        body = { content: content }.to_query

        resp = Motor::NetHttpUtils.post(SEND_FILE_ENPOINT, params.merge(token: auth_token), {}, body)

        parse_json_response_or_throw_error(resp)
      end

      def load_conversations(params = {})
        resp = Motor::NetHttpUtils.get(LOAD_CONVERSATIONS_ENPOINT, params.merge(token: auth_token))

        parse_json_response_or_throw_error(resp)
      end

      def load_users(params = {})
        resp = Motor::NetHttpUtils.get(LOAD_USERS_ENPOINT, params.merge(token: auth_token))

        parse_json_response_or_throw_error(resp)
      end

      def parse_json_response_or_throw_error(resp)
        data = JSON.parse(resp.body)

        raise ApiError, resp.body unless data['ok']

        data
      end

      def auth_token
        return ENV['SLACK_AUTH_TOKEN'] unless defined?(Motor::EncryptedConfig)

        config = Motor::EncryptedConfig.find_by(key: EncryptedConfig::SLACK_CREDENTIALS_KEY)

        return '' unless config

        config.value[:api_key]
      end
    end
  end
end
