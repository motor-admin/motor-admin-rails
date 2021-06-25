# frozen_string_literal: true

ActiveRecord::Filter.module_eval do
  def filters
    @filters ||= HashWithIndifferentAccess.new
  end
end

if Rails::VERSION::MAJOR == 6
  ActiveRecord::Relation::Filter.module_eval do
    def build_arel(aliases = nil)
      arel = super
      my_alias_tracker = ActiveRecord::Associations::AliasTracker.create(connection, table.name, [])
      build_filters(arel, my_alias_tracker)
      arel
    end
  end
end
