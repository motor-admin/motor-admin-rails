# frozen_string_literal: true

module Motor
  class Config < ::Motor::ApplicationRecord
    audited

    if Rails.version.to_f >= 7.1
      serialize :value, coder: HashSerializer
    else
      serialize :value, HashSerializer
    end
  end
end
