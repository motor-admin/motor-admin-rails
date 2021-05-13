# frozen_string_literal: true

module Motor
  class Audit < Audited::Audit
    self.table_name = 'motor_audits'

    serialize :audited_changes, HashSerializer
  end
end
