# frozen_string_literal: true

if ENV['READONLY']
  ActiveRecord::Base.class_eval do
    def readonly?
      true
    end
  end
end
