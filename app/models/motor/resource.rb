# frozen_string_literal: true

module Motor
  class Resource < ::Motor::ApplicationRecord
    audited

    attribute :preferences, default: -> { ActiveSupport::HashWithIndifferentAccess.new }
    serialize :preferences, HashSerializer
  end
end
