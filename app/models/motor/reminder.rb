# frozen_string_literal: true

module Motor
  class Reminder < ::Motor::ApplicationRecord
    audited

    belongs_to :record, polymorphic: true, optional: true
    belongs_to :author, polymorphic: true
    belongs_to :recipient, polymorphic: true

    has_many :notifications, as: :record, dependent: :destroy
  end
end
