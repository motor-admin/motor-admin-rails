# frozen_string_literal: true

class Product < ApplicationRecord
  CATEGORIES = %w[fanfiction humor mythology fantasy].freeze

  has_one_attached :image, **(Rails::VERSION::MAJOR > 5 ? { service: :product_assets } : {})

  has_many :line_items, dependent: :destroy
  has_many :orders, through: :line_items, dependent: :destroy
  has_many :customers, through: :orders, dependent: :destroy

  validates :description, presence: true
  validates :name, presence: true
  validates :price, presence: true, numericality: true
  validates :release_year,
            numericality: {
              less_than_or_equal_to: ->(_) { Time.current.year }
            },
            length: { is: 4 },
            allow_blank: true
  validates :slug, uniqueness: true
  validate :valid_slug
  validates :category, presence: true, inclusion: { in: CATEGORIES }

  def name=(value)
    self.slug = value.to_s.parameterize

    super
  end

  private

  def valid_slug
    errors.add :name, 'must have letters or numbers for the URL' if slug.blank?
  end
end
