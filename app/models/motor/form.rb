# frozen_string_literal: true

module Motor
  class Form < ::Motor::ApplicationRecord
    audited

    belongs_to :author, polymorphic: true, optional: true

    has_many :taggable_tags, as: :taggable
    has_many :tags, through: :taggable_tags, class_name: 'Motor::Tag'

    serialize :preferences, HashSerializer

    scope :active, -> { where(deleted_at: nil) }
  end
end
