# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'activerecord-sqlserver-adapter'
gem 'bootsnap', require: false
gem 'devise'
gem 'faker'
gem 'image_processing'
gem 'mysql2'
gem 'oj'
gem 'pg'
gem 'puma'
gem 'rails', ENV.fetch('RAILS_VERSION', '>= 0')
gem 'tiny_tds'

group :development do
  gem 'brakeman', require: false
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'yard', require: false
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'letter_opener'
  gem 'pry-rails'
  gem 'simplecov', require: false
  gem 'sqlite3'
end

group :test do
  gem 'capybara'
  gem 'cuprite'
  gem 'rspec-rails'
  gem 'webmock'
  gem 'webrick'
end

group :production do
  gem 'aws-sdk-s3', require: false
end
