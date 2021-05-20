# frozen_string_literal: true

module Motor
  module BuildSchema
    module Utils
      ABBREVIATIONS = {
        'id' => 'ID',
        'url' => 'URL',
        'iso' => 'ISO',
        'vip' => 'VIP',
        'ip' => 'IP',
        'zip' => 'ZIP'
      }.freeze

      module_function

      def slugify(model)
        model.name.underscore.pluralize.gsub('/', '__')
      end

      def classify_slug(slug)
        slug.singularize.gsub('__', '/').classify.constantize
      end

      def humanize_column_name(column_name)
        ABBREVIATIONS.fetch(column_name, column_name.humanize)
      end
    end
  end
end
