# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    sequence(:name) { |i| "Product #{i}" }
    sequence(:price) { (200..400).to_a.sample }
    sequence(:description) { |i| "test-description-#{i}" }
    sequence(:category) { Product::CATEGORIES.sample }
    sequence(:release_year) { (1990..Time.current.year).to_a.sample }
  end

  factory :order do
    customer

    sequence(:address_line_one) { Faker::Address.street_address }
    sequence(:address_line_two) { Faker::Address.secondary_address }
    sequence(:address_city) { Faker::Address.city }
    sequence(:address_state) { Faker::Address.state_abbr }
    sequence(:address_zip) { Faker::Address.zip }
    sequence(:status) { Order::STATUSES.sample }
  end

  factory :customer do
    sequence(:name) { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    sequence(:email) { Faker::Internet.email }
    sequence(:country_code) { Country.pluck(:code).sample }
    sequence(:kind) { Customer::KINDS.sample }
    sequence(:reputation) { (20..90).to_a.sample }
  end
end
