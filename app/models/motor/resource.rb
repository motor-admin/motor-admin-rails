# frozen_string_literal: true

module Motor
  class Resource < ::Motor::ApplicationRecord
    audited

    attribute :preferences, default: -> { ActiveSupport::HashWithIndifferentAccess.new }

    if Rails.version.to_f >= 7.1
      serialize :preferences, coder: HashSerializer
    else
      serialize :preferences, HashSerializer
    end
  end
end
