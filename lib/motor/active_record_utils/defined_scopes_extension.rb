# frozen_string_literal: true

module Motor
  module ActiveRecordUtils
    module DefinedScopesExtension
      def inherited(subclass)
        super

        subclass.instance_variable_set(:@__scopes__, subclass.superclass.instance_variable_get(:@__scopes__).dup)
      end

      def scope(name, _body)
        (@__scopes__ ||= []) << name.to_sym

        super
      end

      def defined_scopes
        @__scopes__ || []
      end
    end
  end
end

ActiveSupport.on_load(:active_record) { extend Motor::ActiveRecordUtils::DefinedScopesExtension }
