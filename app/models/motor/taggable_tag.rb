# frozen_string_literal: true

module Motor
  class TaggableTag < ::Motor::ApplicationRecord
    belongs_to :tag
    belongs_to :taggable, polymorphic: true
  end
end
