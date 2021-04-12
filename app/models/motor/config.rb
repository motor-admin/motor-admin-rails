# frozen_string_literal: true

module Motor
  class Config < ApplicationRecord
    serialize :value, HashSerializer
  end
end
