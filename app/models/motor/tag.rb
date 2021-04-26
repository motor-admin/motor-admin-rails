# frozen_string_literal: true

module Motor
  class Tag < ::Motor::ApplicationRecord
    has_many :taggable_tags
  end
end
