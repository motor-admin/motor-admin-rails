# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  attribute :role, :string, default: 'admin'

  def test
    '/sidekiq'
  end
end
