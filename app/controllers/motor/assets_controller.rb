# frozen_string_literal: true

module Motor
  class AssetsController < ActionController::Metal
    CACHE_STORE = ActiveSupport::Cache::MemoryStore.new

    def show
      filename = params[:filename]

      return [404, {}, ''] unless Motor::Assets.manifest.values.include?(filename)

      self.response_body = CACHE_STORE.fetch(filename) do
        Motor::Assets.load_asset(filename)
      end

      headers['Content-Type'] = Marcel::MimeType.for(name: filename)
      headers['Cache-Control'] = 'max-age=31536000'
    end
  end
end
