# frozen_string_literal: true

module Motor
  class Notification < ::Motor::ApplicationRecord
    STATUSES = [
      PENDING = 'pending'
    ].freeze

    belongs_to :record, polymorphic: true, optional: true
    belongs_to :recipient, polymorphic: true

    attribute :status, type: :string, default: PENDING
  end
end
