# frozen_string_literal: true

module Motor
  class Resource < ::Motor::ApplicationRecord
    audited

    serialize :preferences, HashSerializer
  end
end
