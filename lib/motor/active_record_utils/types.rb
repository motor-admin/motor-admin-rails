# frozen_string_literal: true

module Motor
  module ActiveRecordUtils
    module Types
      MUTEX = Mutex.new
      DEFAULT_TYPE = 'string'

      module_function

      def all
        @all || MUTEX.synchronize do
          @all ||= build_types_hash
        end
      end

      def find_class_for_name(name)
        all.invert[name.to_s]
      end

      def find_name_for_class(klass)
        name = all[klass.to_s]

        return name if name

        DEFAULT_TYPE
      end

      def build_types_hash
        type_map = ActiveRecord::Base.connection.send(:type_map)

        type_map.instance_variable_get('@mapping').map do |name, type|
          next unless name.is_a?(String)

          [type.call.class.to_s, name]
        end.compact.to_h
      end
    end
  end
end
