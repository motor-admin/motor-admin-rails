# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

LineItem.destroy_all
User.destroy_all
Order.destroy_all
Customer.destroy_all
Product.destroy_all
Country.destroy_all

ORDER_USED_IN_FORM_ID = 23

%w[admin sales ops].each do |role|
  User.create!(
    email: "#{role}@example.com",
    role: role,
    password: '123456'
  )
end

countries = Country.create!(
  [
    { code: 'US', name: 'USA' },
    { code: 'CA', name: 'Canada' },
    { code: 'MX', name: 'Mexico' }
  ]
)

customer_attributes = Array.new(120) do
  name = "#{Faker::Name.first_name} #{Faker::Name.last_name}"

  {
    name: name,
    reputation: (20..100).to_a.sample,
    email: Faker::Internet.email(name: name),
    territory: countries.sample,
    kind: Customer::KINDS.sample
  }
end

customers = Customer.create!(customer_attributes)

product_attributes = Array.new(30) do
  {
    name: Faker::Book.unique.title,
    price: (99..9999).to_a.sample,
    description: Faker::Lorem.paragraph(sentence_count: 10),
    release_year: (1990..2021).to_a.sample,
    category: Product::CATEGORIES.sample,
    image: {
      io: StringIO.new(
        Motor::NetHttpUtils.get(
          "https://loremflickr.com#{Motor::NetHttpUtils.get('https://loremflickr.com/320/240/book')['Location']}"
        ).body
      ),
      filename: 'image.jpg'
    }
  }
end

Product.create!(product_attributes)

order_statuses = %w[pending delivered]

customers.each do |customer|
  (1..3).to_a.sample.times do
    order = Order.create!(
      customer: customer,
      address_line_one: Faker::Address.street_address,
      address_line_two: Faker::Address.secondary_address,
      address_city: Faker::Address.city,
      address_state: Faker::Address.state_abbr,
      address_zip: Faker::Address.zip,
      status: order_statuses.sample,
      created_at: Time.current - (0..150).to_a.sample.days
    )

    item_count = (1..3).to_a.sample

    Product.all.sample(item_count).each do |product|
      LineItem.create!(
        order: order,
        product: product,
        unit_price: product.price,
        quantity: (1..3).to_a.sample
      )
    end
  end
end

Order.find(ORDER_USED_IN_FORM_ID).update(customer: Customer.find_by(country_code: :US))
