# frozen_string_literal: true

module Motor
  class IconsController < ApiBaseController
    skip_authorization_check

    CACHE_STORE = ActiveSupport::Cache::MemoryStore.new

    def index
      data = CACHE_STORE.fetch('icons') do
        Motor::Assets.icons.map do |icon|
          svg = Motor::Assets.load_asset(icon, gzip: !Motor.development?)
          svg = ActiveSupport::Gzip.decompress(svg) unless Motor.development?

          [icon.split('/').last, svg]
        end
      end

      render json: { data: data }
    end
  end
end
