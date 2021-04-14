# frozen_string_literal: true

module Motor
  class AlertLock < ApplicationRecord
    belongs_to :alert
  end
end
