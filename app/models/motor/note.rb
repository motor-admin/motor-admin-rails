# frozen_string_literal: true

module Motor
  class Note < ::Motor::ApplicationRecord
    audited

    belongs_to :author, polymorphic: true, optional: true
    belongs_to :record, polymorphic: true

    has_many :note_tag_tags, dependent: :destroy
    has_many :tags, through: :note_tag_tags, class_name: 'Motor::NoteTag'

    has_many :reminders, as: :record, dependent: :destroy
    has_many :notifications, as: :record, dependent: :destroy

    scope :active, -> { where(deleted_at: nil) }
  end
end
