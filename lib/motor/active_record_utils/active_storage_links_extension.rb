# frozen_string_literal: true

module Motor
  module ActiveRecordUtils
    module ActiveStorageLinksExtension
      def path
        Rails.application.routes.url_helpers.rails_blob_path(self, only_path: true)
      end
    end
  end
end
