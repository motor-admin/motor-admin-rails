# frozen_string_literal: true

module Motor
  class Config < ::Motor::ApplicationRecord
    audited

    serialize :value, HashSerializer
  end
end
