# frozen_string_literal: true

module Motor
  module Tags
    module_function

    def assign_tags(taggable, tags)
      return taggable unless tags

      tags.each do |tag_name|
        next if taggable.taggable_tags.find { |tt| tt.tag.name.casecmp(tag_name).zero? }

        tag = Tag.find_or_initialize_by(name: tag_name)

        taggable.taggable_tags.new(tag: tag)
      end

      remove_missing_tags(taggable, tags) if taggable.persisted?

      taggable
    end

    def remove_missing_tags(taggable, tags)
      downcase_tags = tags.map(&:downcase)
      tags_to_remove = taggable.tags.reject { |tt| tt.name.downcase.in?(downcase_tags) }

      taggable.tags -= tags_to_remove

      taggable
    end
  end
end
