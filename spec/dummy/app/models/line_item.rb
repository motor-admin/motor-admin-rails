# frozen_string_literal: true

class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :unit_price, presence: true
  validates :quantity, presence: true

  def total_price
    unit_price * quantity
  end
end
