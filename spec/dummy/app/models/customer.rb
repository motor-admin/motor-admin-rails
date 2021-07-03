# frozen_string_literal: true

class Customer < ApplicationRecord
  KINDS = %w[
    standard
    vip
  ].freeze

  has_rich_text :bio if defined?(ActionText)

  attribute :kind, :string, default: 'standard'
  attribute :reputation, :integer, default: 0

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

  def monthly_sales_diff
    (orders.select { |o| Time.current.all_month.cover?(o.created_at) }.sum(&:total_price) -
     orders.select { |o| 1.month.ago.all_month.cover?(o.created_at) }.sum(&:total_price)) / 100
  end

  def sales_per_year
    dates = (0..12).map { |i| [i.month.ago.beginning_of_month, 0] }.reverse.to_h

    orders.each_with_object(dates) do |order, acc|
      next unless acc[order.created_at.beginning_of_month]

      acc[order.created_at.beginning_of_month] += order.total_price
    end.values
  end
end
