if Rails.gem_version >= Gem::Version.new("7.2")
  require 'audited/audit'

  Audited::Audit.abstract_class = true
end
