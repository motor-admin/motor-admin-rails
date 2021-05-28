# frozen_string_literal: true

module ActiveRecordHelpers
  def load_random(model)
    model.offset(rand(model.count)).take
  end
end
