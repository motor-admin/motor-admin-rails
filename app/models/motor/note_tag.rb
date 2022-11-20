# frozen_string_literal: true

module Motor
  class NoteTag < ::Motor::ApplicationRecord
    has_many :note_tag_tags, dependent: :destroy
  end
end
