# frozen_string_literal: true

module Motor
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    self.table_name_prefix = 'motor_'
  end
end
