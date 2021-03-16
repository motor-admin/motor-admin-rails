# frozen_string_literal: true

module Motor
  class Query < ApplicationRecord
    belongs_to :author, polymorphic: true, optional: true

    has_many :taggable_tags, as: :taggable
    has_many :tags, through: :taggable_tags, class_name: 'Motor::Tag'

    serialize :preferences, HashSerializer
  end
end
