# frozen_string_literal: true

module Motor
  class Resource < ::Motor::ApplicationRecord
    serialize :preferences, HashSerializer
  end
end
