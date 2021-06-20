# frozen_string_literal: true

module Motor
  module Queries
    module RenderSqlTemplate
      SECTION_OPEN_REGEXP = /{{([#^])\s*(\w+)}}.*\z/m.freeze
      VARIABLE_REGEXP = /{{\s*(\w+)\s*}}/m.freeze

      module_function

      def call(sql, variables)
        result = render_sections(sql, variables)

        interpolate_variables(result, variables)
      end

      def interpolate_variables(sql, variables)
        selected_variables = []

        rendered =
          sql.gsub(VARIABLE_REGEXP) do
            variable_name = Regexp.last_match[1]

            index = selected_variables.index { |name, _| name == variable_name }
            variable_values = variables[variable_name]

            if variable_values.is_a?(Array)
              first_variable_index = selected_variables.size + 1

              variable_values.each { |value| selected_variables << [variable_name, value] } unless index

              (first_variable_index..selected_variables.size).map { |i| "$#{i}" }.join(', ')
            else
              selected_variables << [variable_name, variables[variable_name]] unless index

              "$#{selected_variables.size}"
            end
          end

        [rendered, selected_variables]
      end

      def render_sections(sql, variables)
        sql.sub(SECTION_OPEN_REGEXP) do |e|
          variable_name = Regexp.last_match[2]
          is_negative = Regexp.last_match[1] == '^'

          _, content, rest = e.split(build_section_close_regexp(variable_name), 3)

          is_present = variables[variable_name].present?

          render_sections(is_present ^ is_negative ? content + rest.to_s : rest, variables)
        end
      end

      def build_section_close_regexp(variable_name)
        %r{{{[#^/]s*#{Regexp.escape(variable_name)}\s*}}}m
      end
    end
  end
end
