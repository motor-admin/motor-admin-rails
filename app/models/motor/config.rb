# frozen_string_literal: true

module Motor
  class Config < ::Motor::ApplicationRecord
    serialize :value, HashSerializer
  end
end
