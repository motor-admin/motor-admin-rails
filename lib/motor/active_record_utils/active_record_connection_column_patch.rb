# frozen_string_literal: true

begin
  require 'active_record/connection_adapters/deduplicable'
rescue LoadError
  nil
end

ActiveRecord::ConnectionAdapters::Column.class_eval do
  def array
    false
  end
  alias_method :array?, :array
end
