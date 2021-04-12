# frozen_string_literal: true

module Motor
  class Resource < ApplicationRecord
    serialize :preferences, HashSerializer
  end
end
