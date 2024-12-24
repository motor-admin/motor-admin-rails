# frozen_string_literal: true

unless defined?(Motor::Audit)
  module Motor
    class Audit < Audited::Audit
      self.table_name = 'motor_audits'

      if Rails.version.to_f >= 7.2
        superclass.abstract_class = true
      end

      if Rails.version.to_f >= 7.1
        serialize :audited_changes, coder: HashSerializer
      else
        serialize :audited_changes, HashSerializer
      end
    end
  end
end
