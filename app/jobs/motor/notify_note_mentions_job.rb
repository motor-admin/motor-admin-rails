# frozen_string_literal: true

module Motor
  class NotifyNoteMentionsJob < ApplicationJob
    def perform(note, current_user)
      Motor::Notes::NotifyMentions.call(note, current_user)
    end
  end
end
