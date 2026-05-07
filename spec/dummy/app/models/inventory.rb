# frozen_string_literal: true

class Inventory < ApplicationRecord
  self.primary_key = %i[product_id warehouse_code]

  belongs_to :product

  validates :warehouse_code, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
end
