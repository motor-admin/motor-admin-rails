# frozen_string_literal: true

class Order < ApplicationRecord
  STATUSES = %w[pending shipped delivered canceled].freeze

  belongs_to :customer

  has_many :line_items, dependent: :destroy
  has_many :notes, as: :record

  validates :address_line_one, presence: true
  validates :address_line_two, presence: true
  validates :address_city, presence: true
  validates :address_state, presence: true
  validates :address_zip, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: :pending) }
  scope :canceled, -> { where(status: :canceled) }
  scope :shipped, -> { where(status: :shipped) }
  scope :delivered, -> { where(status: :delivered) }

  def total_price
    line_items.sum(&:total_price)
  end

  def ship!
    update!(
      status: :shipped,
      shipped_at: Time.current
    )
  end

  def map_link
    "https://www.google.com/maps?q=#{address_state},US"
  end
end
