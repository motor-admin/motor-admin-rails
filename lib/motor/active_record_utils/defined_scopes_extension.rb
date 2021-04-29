# frozen_string_literal: true

module Motor
  module ActiveRecordUtils
    module DefinedScopesExtension
      def scope(name, _body)
        (@__scopes__ ||= []) << name

        super
      end

      def defined_scopes
        @__scopes__ || []
      end
    end
  end
end

ActiveRecord::Base.extend(Motor::ActiveRecordUtils::DefinedScopesExtension)
