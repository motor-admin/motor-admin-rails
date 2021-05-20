# frozen_string_literal: true

class OrderNote < ApplicationRecord
  belongs_to :order
end
