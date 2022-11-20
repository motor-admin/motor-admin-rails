# frozen_string_literal: true

module Motor
  class NotesChannel < ::Motor::ApplicationCable::Channel
    def subscribed
      stream_from "motor:notes:#{params[:room]}"
    end
  end
end
