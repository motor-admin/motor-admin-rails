# frozen_string_literal: true

module Motor
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    self.table_name_prefix = 'motor_'

    def self.audited(*args)
      default_class = Audited.audit_class

      Audited.audit_class = 'Motor::Audit'

      super
    ensure
      Audited.audit_class = default_class
    end
  end
end
