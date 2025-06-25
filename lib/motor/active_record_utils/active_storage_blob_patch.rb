# frozen_string_literal: true

module Motor
  module ActiveRecordUtils
    module ActiveStorageBlobPatch
      KEYWORD_ARGS =
        %i[io filename content_type metadata service_name identify record key].freeze

      def build_after_unfurling(hash)
        super(**normalize_io_args(hash))
      end

      def create_after_unfurling!(hash)
        super(**normalize_io_args(hash))
      end

      def build_after_upload(hash)
        super(**normalize_io_args(hash))
      end

      def create_after_upload!(hash)
        super(**normalize_io_args(hash))
      end

      def create_and_upload!(hash)
        super(**normalize_io_args(hash))
      end

      private

      def normalize_io_args(hash)
        args = hash.with_indifferent_access.slice(*KEYWORD_ARGS).symbolize_keys

        if args[:io].is_a?(String) && !args[:io].respond_to?(:rewind)
          args[:io] = StringIO.new(args[:io].b)
        end

        if args[:content_type].blank? && args[:io].respond_to?(:read)
          peek = args[:io].read(512)
          args[:io].rewind
          args[:content_type] = Marcel::MimeType.for(StringIO.new(peek)) || "application/octet-stream"
        end

        args
      end
    end
  end
end
