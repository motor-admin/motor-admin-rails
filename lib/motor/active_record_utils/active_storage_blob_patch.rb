# frozen_string_literal: true

module Motor
  module ActiveRecordUtils
    module ActiveStorageBlobPatch
      KEYWORD_ARGS =
        %i[io filename content_type metadata service_name identify record].freeze

      def build_after_upload(hash)
        super(**hash.with_indifferent_access.slice(*KEYWORD_ARGS).symbolize_keys)
      end

      def build_after_unfurling(hash)
        super(**hash.with_indifferent_access.slice(*KEYWORD_ARGS).symbolize_keys)
      end

      def create_after_upload!(hash)
        super(**hash.with_indifferent_access.slice(*KEYWORD_ARGS).symbolize_keys)
      end

      def create_after_unfurling!(hash)
        super(**hash.with_indifferent_access.slice(*KEYWORD_ARGS).symbolize_keys)
      end

      def create_and_upload!(hash)
        super(**hash.with_indifferent_access.slice(*KEYWORD_ARGS).symbolize_keys)
      end
    end
  end
end
