# frozen_string_literal: true

module Motor
  class NoteTagTag < ::Motor::ApplicationRecord
    belongs_to :tag, class_name: 'Motor::NoteTag'
    belongs_to :note
  end
end
