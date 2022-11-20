# frozen_string_literal: true

module Motor
  module Notes
    module Tags
      module_function

      def assign_tags(note, tags)
        return note if tags.blank?

        tags.each do |tag_name|
          next if note.note_tag_tags.find { |tt| tt.tag.name.casecmp(tag_name).zero? }

          tag = NoteTag.find_or_initialize_by(name: tag_name)

          note.note_tag_tags.new(tag: tag)
        end

        remove_missing_tags(note, tags) if note.persisted?

        note
      end

      def remove_missing_tags(note, tags)
        downcase_tags = tags.map(&:downcase)
        tags_to_remove = note.tags.reject { |tt| tt.name.downcase.in?(downcase_tags) }

        note.tags -= tags_to_remove

        note
      end
    end
  end
end
