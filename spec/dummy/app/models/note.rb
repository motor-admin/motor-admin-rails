# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :record, polymorphic: true

  has_many_attached :images

  enum :sentiment, %i[negative neutral positive], default: :negative
end
