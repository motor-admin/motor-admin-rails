# frozen_string_literal: true

class Customer < ApplicationRecord
  KINDS = %w[
    standard
    vip
  ].freeze

  has_rich_text :bio if defined?(ActionText)

  attribute :kind, :string, default: 'standard'

  has_many :orders, dependent: :destroy
  has_many :notes, through: :orders, dependent: :destroy
  has_many :line_items, through: :orders, dependent: :destroy

  belongs_to :territory,
             class_name: 'Country',
             foreign_key: :country_code,
             primary_key: :code

  validates :name, presence: true
  validates :email, presence: true
  validates :kind, presence: true, inclusion: { in: KINDS }

  scope :vip, -> { where(kind: :vip) }
  scope :standard, -> { where(kind: :standard) }

  def lifetime_value
    orders.sum(&:total_price)
  end
end
