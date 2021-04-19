# frozen_string_literal: true

module Motor
  module ActiveRecordUtils
    module FetchMethods
      EXCLUDE_METHODS = %i[
        password
        current_password
        password_confirmation
        devise_modules
      ].freeze

      module_function

      def call(model)
        (model.instance_methods(false) - model.superclass.instance_methods).reject do |name|
          next true if EXCLUDE_METHODS.include?(name)
          next true if name.to_s.match?(/(:?=|\?|_id)\z/)
          next true if name.to_s.match?(/\A(?:validate|autosave)_associated_records/)
        end
      end
    end
  end
end
