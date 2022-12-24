# frozen_string_literal: true

module Motor
  class Alert < ::Motor::ApplicationRecord
    audited

    belongs_to :query
    belongs_to :author, polymorphic: true, optional: true

    has_many :alert_locks, dependent: :destroy
    has_many :taggable_tags, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggable_tags, class_name: 'Motor::Tag'

    attribute :preferences, default: -> { ActiveSupport::HashWithIndifferentAccess.new }
    serialize :preferences, HashSerializer

    scope :active, -> { where(deleted_at: nil) }
    scope :enabled, -> { where(is_enabled: true) }

    def cron
      @cron ||=
        Fugit::Nat.parse("#{preferences[:interval]} #{ActiveSupport::TimeZone::MAPPING[preferences[:timezone]]}")
    end
  end
end
