# frozen_string_literal: true

module Motor
  module CancanUtils
    module AbilityPatch
      def serialized_rules
        return [] unless @rules

        @rules.map do |rule|
          {
            base_behavior: rule.base_behavior,
            actions: expand_actions(rule.actions),
            subjects: rule.subjects.map(&:to_s),
            attributes: rule.attributes,
            conditions: rule.conditions.as_json
          }
        end
      end

      def rules_hash
        serialized_rules.hash
      end

      private

      def default_alias_actions
        super.merge(destroy: %i[remove delete])
      end
    end
  end
end
