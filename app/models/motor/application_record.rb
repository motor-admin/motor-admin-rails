# frozen_string_literal: true

module Motor
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
