# frozen_string_literal: true

module ActiveRecord
  class UnkownFilterError < NoMethodError
  end
end

module Arel
  module Attributes
    class Relation < Attribute
      attr_accessor :collection, :for_write

      def initialize(relation, name, collection = false, for_write = false)
        self[:relation] = relation
        self[:name] = name
        @collection = collection
        @for_write = for_write
      end

      delegate :able_to_type_cast?, to: :relation

      def table_name
        nil
      end

      def eql?(other)
        self.class == other.class &&
          relation == other.relation &&
          name == other.name &&
          collection == other.collection
      end

      delegate :type_cast_for_database, to: :relation
    end
  end
end

module Arel
  module Visitors
    class ToSql
      def visit_Arel_Attributes_Relation(o, collector)
        visit(o.relation, collector)
      end
    end
  end
end

module ActiveRecord
  module Associations
    class AliasTracker
      def initialize(connection, aliases)
        @aliases    = aliases
        @connection = connection
        @relation_trail = {}
      end

      def aliased_table_for_relation(trail, arel_table, &block)
        @relation_trail[trail] ||=
          if Rails::VERSION::MAJOR >= 6
            aliased_table_for(arel_table, &block)
          else
            aliased_table_for(arel_table.name, trail.last, nil)
          end
      end
    end
  end
end

module ActiveRecord
  class PredicateBuilder # :nodoc:
    def self.filter_joins(klass, filters)
      custom = []
      [build_filter_joins(klass, filters, [], custom), custom]
    end

    def self.build_filter_joins(klass, filters, relations = [], custom = [])
      case filters
      when Array
        filters.each { |f| build_filter_joins(klass, f, relations, custom) }.compact
      when Hash
        filters.each do |key, value|
          if klass.respond_to?(:filters) && klass.filters.key?(key.to_sym)
            js = klass.filters.dig(key.to_sym, :joins)

            if js.is_a?(Array)
              js.each do |j|
                if j.is_a?(String)
                  custom << j
                else
                  relations << j
                end
              end
            elsif js
              if js.is_a?(String)
                custom << js
              else
                relations << js
              end
            end
          elsif reflection = klass._reflections[key.to_s]
            if value.is_a?(Hash)
              relations <<
                if reflection.polymorphic?
                  value = value.dup
                  join_klass = value.delete(:as).safe_constantize
                  right_table = join_klass.arel_table
                  left_table = reflection.active_record.arel_table

                  on = right_table[join_klass.primary_key]
                       .eq(left_table[reflection.foreign_key])
                       .and(left_table[reflection.foreign_type].eq(join_klass.name))

                  cross_boundry_joins = join_klass.left_outer_joins(ActiveRecord::PredicateBuilder.filter_joins(join_klass, value).flatten).send(
                    :build_joins, []
                  )

                  [
                    left_table.join(right_table, Arel::Nodes::OuterJoin).on(on).join_sources,
                    cross_boundry_joins
                  ]
                else
                  {
                    key => build_filter_joins(reflection.klass, value, [], custom)
                  }
                end
            elsif value.is_a?(Array)
              value.each do |v|
                relations << {
                  key => build_filter_joins(reflection.klass, v, [], custom)
                }
              end
            elsif value != true && value != false && value != 'true' && value != 'false' && !value.nil?
              relations << key
            end
          elsif !klass.columns_hash.key?(key.to_s) && key.to_s.end_with?('_ids') && reflection = klass._reflections[key.to_s.gsub(
            /_ids$/, 's'
          )]
            relations << reflection.name
          elsif reflection = klass.reflect_on_all_associations(:has_and_belongs_to_many).find do |r|
                  r.join_table == key.to_s && value.keys.first.to_s == r.association_foreign_key.to_s
                end
            reflection = klass._reflections[klass._reflections[reflection.name.to_s].send(:delegate_reflection).options[:through].to_s]
            relations << { reflection.name => build_filter_joins(reflection.klass, value) }
          end
        end
      end

      relations
    end

    def build_from_filter_hash(attributes, relation_trail, alias_tracker)
      case attributes
      when Array
        node = build_from_filter_hash(attributes.shift, relation_trail, alias_tracker)

        n = attributes.shift(2)
        until n.empty?
          n[1] = build_from_filter_hash(n[1], relation_trail, alias_tracker)
          if n[0] == 'AND'
            if node.is_a?(Arel::Nodes::And)
              node.children.push(n[1])
            else
              node = node.and(n[1])
            end
          elsif n[0] == 'OR'
            node = Arel::Nodes::Grouping.new(node).or(Arel::Nodes::Grouping.new(n[1]))
          elsif !n[0].is_a?(String)
            n[0] = build_from_filter_hash(n[0], relation_trail, alias_tracker)
            if node.is_a?(Arel::Nodes::And)
              node.children.push(n[0])
            else
              node = node.and(n[0])
            end
          else
            raise 'lll'
          end
          n = attributes.shift(2)
        end

        node
      when Hash
        expand_from_filter_hash(attributes, relation_trail, alias_tracker)
      else
        expand_from_filter_hash({ id: attributes }, relation_trail, alias_tracker)
      end
    end

    def expand_from_filter_hash(attributes, relation_trail, alias_tracker)
      klass = table.send(:klass)

      children = attributes.flat_map do |key, value|
        if klass.respond_to?(:filters) && custom_filter = klass.filters[key]
          instance_exec(klass, table, key, value, relation_trail, alias_tracker, &custom_filter[:block])
        elsif column = klass.columns_hash[key.to_s] || klass.columns_hash[key.to_s.split('.').first]
          expand_filter_for_column(key, column, value, relation_trail)
        elsif relation = klass.reflect_on_association(key)
          expand_filter_for_relationship(relation, value, relation_trail, alias_tracker)
        elsif key.to_s.end_with?('_ids') && relation = klass.reflect_on_association(key.to_s.gsub(/_ids$/, 's'))
          expand_filter_for_relationship(relation, { id: value }, relation_trail, alias_tracker)
        elsif relation = klass.reflect_on_all_associations(:has_and_belongs_to_many).find do |r|
                r.join_table == key.to_s && value.keys.first.to_s == r.association_foreign_key.to_s
              end
          expand_filter_for_join_table(relation, value, relation_trail, alias_tracker)
        else
          raise ActiveRecord::UnkownFilterError, "Unkown filter \"#{key}\" for #{klass}."
        end
      end

      children.compact!
      if children.size > 1
        Arel::Nodes::And.new(children)
      else
        children.first
      end
    end

    def expand_filter_for_column(key, column, value, relation_trail)
      attribute = table.send(:arel_table)[column.name]
      relation_trail.each do |rt|
        attribute = Arel::Attributes::Relation.new(attribute, rt)
      end

      if column.type == :json || column.type == :jsonb
        names = key.to_s.split('.')
        names.shift
        attribute = attribute[names]
      end

      if value.is_a?(Hash)
        nodes = value.map do |subkey, subvalue|
          expand_filter_for_arel_attribute(column, attribute, subkey, subvalue)
        end
        nodes.inject { |c, n| c.nil? ? n : c.and(n) }
      elsif value.nil?
        attribute.eq(nil)
      elsif [true, 'true'].include?(value)
        column.type == :boolean ? attribute.eq(true) : attribute.not_eq(nil)
      elsif [false, 'false'].include?(value)
        column.type == :boolean ? attribute.eq(false) : attribute.eq(nil)
      elsif value.is_a?(Array) && !column.array
        attribute.in(value)
      elsif column.type != :json && column.type != :jsonb
        converted_value = column.array ? Array(value) : value
        attribute.eq(converted_value)
      else
        raise ActiveRecord::UnkownFilterError, "Unkown type for #{column}. (type #{value.class})"
      end
    end

    def expand_filter_for_arel_attribute(column, attribute, key, value)
      case key.to_sym
      when :contains
        attribute.contains(Arel::Nodes::Casted.new(column.array ? Array(value) : value, attribute))
      when :contained_by
        attribute.contained_by(Arel::Nodes::Casted.new(column.array ? Array(value) : value, attribute))
      when :equal_to, :eq
        attribute.eq(value)
      when :excludes
        attribute.excludes(Arel::Nodes::Casted.new(column.array ? Array(value) : value, attribute))
      when :greater_than, :gt
        attribute.gt(value)
      when :greater_than_or_equal_to, :gteq, :gte
        attribute.gteq(value)
      when :has_key
        attribute.has_key(value)
      when :has_keys
        attribute.has_keys(*Array(value).map { |x| Arel::Nodes.build_quoted(x) })
      when :has_any_key
        attribute.has_any_key(*Array(value).map { |x| Arel::Nodes.build_quoted(x) })
      when :in
        attribute.in(value)
      when :less_than, :lt
        attribute.lt(value)
      when :less_than_or_equal_to, :lteq, :lte
        attribute.lteq(value)
      when :like
        attribute.matches(value, nil, true)
      when :ilike
        attribute.matches(value, nil, false)
      when :not, :not_equal, :neq
        attribute.not_eq(value)
      when :not_in
        attribute.not_in(value)
      when :overlaps
        attribute.overlaps(Arel::Nodes::Casted.new(column.array ? Array(value) : value, attribute))
      when :not_overlaps
        attribute.not_overlaps(value)
      when :ts_match
        if value.is_a?(Array)
          attribute.ts_query(*value)
        else
          attribute.ts_query(value)
        end
      when :within
        case value
        when String
          if /\A[0-9A-F]*\Z/i.match?(value) && value.start_with?('00', '01')
            attribute.within(Arel::Nodes::HexEncodedBinary.new(value))
          else
            attribute.within(Arel::Nodes.build_quoted(value))
          end
        when Hash
          attribute.within(Arel::Nodes.build_quoted(value))
        else
          raise "Not Supported value for within: #{value.inspect}"
        end
      else
        raise "Not Supported: #{key.to_sym} on column \"#{column.name}\" of type #{column.type}"
      end
    end

    def expand_filter_for_relationship(relation, value, relation_trail, alias_tracker)
      case relation.macro
      when :has_many
        case value
        when true, 'true'
          counter_cache_column_name = relation.counter_cache_column || "#{relation.plural_name}_count"
          if relation.active_record.column_names.include?(counter_cache_column_name.to_s)
            return table.arel_table[counter_cache_column_name.to_sym].gt(0)
          else
            raise "Not Supported: #{relation.name}"
          end
        when false, 'false'
          counter_cache_column_name = relation.counter_cache_column || "#{relation.plural_name}_count"
          if relation.active_record.column_names.include?(counter_cache_column_name.to_s)
            return table.arel_table[counter_cache_column_name.to_sym].eq(0)
          else
            raise "Not Supported: #{relation.name}"
          end
        end

      when :belongs_to
        if [true, 'true'].include?(value)
          return table.arel_table[relation.foreign_key].not_eq(nil)
        elsif value == false || value == 'false' || value.nil?
          return table.arel_table[relation.foreign_key].eq(nil)
        end
      end

      if relation.polymorphic?
        value = value.dup
        klass = value.delete(:as).safe_constantize

        builder = self.class.new(TableMetadata.new(
                                   klass,
                                   alias_tracker.aliased_table_for_relation(relation_trail + ["#{klass.table_name}_as_#{relation.name}"],
                                                                            klass.arel_table) do
                                     klass.arel_table.name
                                   end,
                                   relation
                                 ))
        builder.build_from_filter_hash(value, relation_trail + ["#{klass.table_name}_as_#{relation.name}"],
                                       alias_tracker)
      else
        builder = self.class.new(TableMetadata.new(
                                   relation.klass,
                                   alias_tracker.aliased_table_for_relation(relation_trail + [relation.name],
                                                                            relation.klass.arel_table) do
                                     relation.alias_candidate(table.arel_table.name || relation.klass.arel_table)
                                   end,
                                   relation
                                 ))
        builder.build_from_filter_hash(value, relation_trail + [relation.name], alias_tracker)
      end
    end

    def expand_filter_for_join_table(relation, value, relation_trail, alias_tracker)
      relation = relation.active_record._reflections[relation.active_record._reflections[relation.name.to_s].send(:delegate_reflection).options[:through].to_s]
      builder = self.class.new(TableMetadata.new(
                                 relation.klass,
                                 alias_tracker.aliased_table_for_relation(relation_trail + [relation.name],
                                                                          relation.klass.arel_table) do
                                   relation.alias_candidate(table.arel_table.name || relation.klass.arel_table)
                                 end,
                                 relation
                               ))
      builder.build_from_filter_hash(value, relation_trail + [relation.name], alias_tracker)
    end
  end
end

module ActiveRecord
  class Relation
    class FilterClauseFactory # :nodoc:
      def initialize(klass, predicate_builder)
        @klass = klass
        @predicate_builder = predicate_builder
      end

      def build(filters, alias_tracker)
        if filters.is_a?(Hash) || filters.is_a?(Array)
          parts = [predicate_builder.build_from_filter_hash(filters, [], alias_tracker)]
        else
          raise ArgumentError, "Unsupported argument type: #{filters.inspect} (#{filters.class})"
        end

        WhereClause.new(parts)
      end

      protected

      attr_reader :klass, :predicate_builder
    end
  end
end
