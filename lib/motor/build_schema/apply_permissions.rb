# frozen_string_literal: true

module Motor
  module BuildSchema
    module ApplyPermissions
      module_function

      def call(schema, ability)
        schema.map do |model|
          klass = model[:class_name].constantize

          next unless ability.can?(:read, klass)

          model[:associations] = filter_associations(model[:associations], ability)
          model[:columns] = filter_columns(klass, model[:columns], ability)
          model[:actions] = filter_actions(klass, model[:actions], ability)
          model[:tabs] = filter_tabs(klass, model[:tabs], ability)

          model
        end.compact
      end

      def filter_associations(associations, ability)
        associations.select do |assoc|
          model_class = assoc[:model_name].classify.safe_constantize

          model_class && ability.can?(:read, model_class)
        end
      end

      def filter_tabs(_model, tabs, ability)
        tabs = tabs.reject { |t| t[:name] == 'audits' } unless ability.can?(:read, Motor::Audit)
        tabs = tabs.reject { |t| t[:name] == 'notes' } unless ability.can?(:read, Motor::Note)

        tabs
      end

      def filter_columns(model, columns, ability)
        columns.map do |column|
          next unless ability.can?(:read, model, column[:name])

          reference_model_name = column.dig(:reference, :model_name)
          model_class = reference_model_name&.classify&.safe_constantize

          next if reference_model_name &&
                  (model_class.nil? || !ability.can?(:read, model_class))

          if !ability.can?(:update, model, column[:name]) &&
             column[:access_type] != BuildSchema::ColumnAccessTypes::HIDDEN
            column = column.merge(access_type: BuildSchema::ColumnAccessTypes::READ_ONLY)
          end

          column
        end.compact
      end

      def filter_actions(model, actions, ability)
        actions.select do |action|
          ability.can?(action[:name].to_sym, model)
        end
      end
    end
  end
end
