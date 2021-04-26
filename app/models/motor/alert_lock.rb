# frozen_string_literal: true

module Motor
  class AlertLock < ::Motor::ApplicationRecord
    belongs_to :alert
  end
end
