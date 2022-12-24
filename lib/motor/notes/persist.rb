# frozen_string_literal: true

module Motor
  module Notes
    module Persist
      TAG_REGEXP = /#\w+?\b/.freeze

      module_function

      def call(note, current_user)
        note.author ||= current_user

        tags = parse_tag_names(note)

        Motor::Notes::Tags.assign_tags(note, tags)

        note.save!

        broadcast_note(note)

        note
      end

      def broadcast_note(note)
        Motor::NotesChannel.broadcast_to(
          note.values_at(:record_type, :record_id).join(':'),
          ['update', note.as_json(include: %i[author tags reminders])]
        )
      end

      def parse_tag_names(note)
        note.body.scan(TAG_REGEXP).pluck(1..)
      end
    end
  end
end
