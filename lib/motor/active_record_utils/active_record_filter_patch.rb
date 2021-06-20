# frozen_string_literal: true

ActiveRecord::Filter.module_eval do
  def filters
    @filters ||= HashWithIndifferentAccess.new
  end
end
