# frozen_string_literal: true

module Motor
  class Form < ::Motor::ApplicationRecord
    audited

    belongs_to :author, polymorphic: true, optional: true
    belongs_to :api_config, foreign_key: :api_config_name, primary_key: :name, inverse_of: :form

    has_many :taggable_tags, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggable_tags, class_name: 'Motor::Tag'

    attribute :preferences, default: -> { ActiveSupport::HashWithIndifferentAccess.new }
    serialize :preferences, HashSerializer

    scope :active, -> { where(deleted_at: nil) }
  end
end
