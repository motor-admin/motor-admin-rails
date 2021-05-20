# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'faker'
gem 'oj'
gem 'pg'
gem 'puma'

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
end

group :test do
  gem 'rspec-rails'
  gem 'webrick'
end

group :production do
  gem 'aws-sdk-s3', require: false
end
