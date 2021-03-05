module Motor
  class AssetsController < ActionController::Metal
    CACHE_STORE = ActiveSupport::Cache::MemoryStore.new

    def show
      filename = params[:filename]

      return [404, {}, ''] unless Motor::Assets.manifest.values.include?(filename)

      self.response_body = CACHE_STORE.fetch(filename) do
        Motor::Assets.load_asset(filename)
      end

      self.headers["Content-Type"] = Marcel::MimeType.for(name: filename)
    end
  end
end
