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

    def build_filters(manager, alias_tracker)
      where_clause = nil

      @filters.each do |filters|
        where_clause = filter_clause_factory.build(filters, alias_tracker)

        manager.where(where_clause.ast)
      end

      @values[:where] = where_clause
    end
  end
end
