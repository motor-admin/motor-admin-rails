# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :record, polymorphic: true

  has_many_attached :images

  attribute :sentiment, :integer, default: 0

  enum sentiment: %i[negative neutral positive]
end
