# frozen_string_literal: true

class Country < ApplicationRecord
  validates :code, :name, presence: true
end
