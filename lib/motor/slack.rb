# frozen_string_literal: true

module Motor
  module Slack
    ITEMS_LIMIT = 1000

    module_function

    def conversations
      Slack::Client.load_conversations(limit: ITEMS_LIMIT)['channels'] +
        Slack::Client.load_users(limit: ITEMS_LIMIT)['members']
    end
  end
end

require_relative './slack/client'
