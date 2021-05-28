# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    sequence(:name) { |i| "Product #{i}" }
    sequence(:price) { (200..400).to_a.sample }
    sequence(:description) { |i| "test-description-#{i}" }
    sequence(:category) { Product::CATEGORIES.sample }
    sequence(:release_year) { (1990..Time.current.year).to_a.sample }
  end
end
