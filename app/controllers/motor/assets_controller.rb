# frozen_string_literal: true

module Motor
  class AssetsController < ActionController::Metal
    CACHE_STORE = ActiveSupport::Cache::MemoryStore.new

    GZIP_TYPES = [
      'application/javascript',
      'text/css',
      'image/svg+xml'
    ].freeze

    MIME_TYPES = {
      '.js' => 'application/javascript',
      '.css' => 'text/css',
      '.svg' => 'image/svg+xml',
      '.png' => 'image/png',
      '.woff2' => 'font/woff2'
    }.freeze

    def show
      filename = params[:filename]

      return [404, {}, ''] unless Motor::Assets.manifest.value?(filename)

      assign_headers(filename)

      self.response_body = CACHE_STORE.fetch(filename) do
        Motor::Assets.load_asset(filename, gzip: headers['Content-Encoding'] == 'gzip')
      end
    end

    private

    def assign_headers(filename)
      content_type = MIME_TYPES[File.extname(filename)]

      headers['Content-Type'] = content_type
      headers['Content-Encoding'] = 'gzip' if !Motor.development? && GZIP_TYPES.include?(content_type)
      headers['Cache-Control'] = 'max-age=31536000'
    end
  end
end
