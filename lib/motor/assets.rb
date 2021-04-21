# frozen_string_literal: true

module Motor
  module Assets
    InvalidPathError = Class.new(StandardError)

    ASSETS_PATH = Pathname.new(__dir__).join('../../ui/dist')
    MANIFEST_PATH = ASSETS_PATH.join('manifest.json')
    DEV_SERVER_URL = 'http://localhost:9090/'

    module_function

    def manifest
      JSON.parse(MANIFEST_PATH.read)
    end

    def asset_path(path)
      Motor::Admin.routes.url_helpers.motor_asset_path(manifest[path])
    end

    def load_asset(filename)
      if Motor.development?
        load_from_dev_server(filename)
      else
        load_from_disk(filename)
      end
    end

    def load_from_disk(filename)
      filename += '.gz' if filename.match?(/\.(?:js|css)\z/)

      path = ASSETS_PATH.join(filename)

      raise InvalidPathError unless path.to_s.starts_with?(ASSETS_PATH.to_s)

      path.read
    end

    def load_from_dev_server(filename)
      uri = URI(DEV_SERVER_URL + filename)

      Net::HTTP.get_response(uri).body
    end
  end
end
