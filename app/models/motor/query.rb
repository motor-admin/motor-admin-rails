# frozen_string_literal: true

module Motor
  class Query < ::Motor::ApplicationRecord
    audited

    belongs_to :author, polymorphic: true, optional: true

    has_many :taggable_tags, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggable_tags, class_name: 'Motor::Tag'
    has_many :alerts, dependent: :destroy

    attribute :preferences, default: -> { ActiveSupport::HashWithIndifferentAccess.new }
    serialize :preferences, HashSerializer

    scope :active, -> { where(deleted_at: nil) }

    def result(variables_hash = {})
      result = Motor::Queries::RunQuery.call!(self, variables_hash: variables_hash)
      column_names = result.columns.pluck(:name)

      result.data.map { |row| column_names.zip(row).to_h }
    end
    alias run result
  end
end

ActiveSupport.run_load_hooks(:motor_query, Motor::Query)
