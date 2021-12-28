# frozen_string_literal: true

module Motor
  module ApiConfigs
    METHODS = %w[get post put delete].freeze

    InvalidHttpMethod = Class.new(StandardError)

    module_function

    def run(api_config, method: nil, path: nil, body: nil, params: {}, headers: {})
      method ||= 'get'

      raise InvalidHttpMethod unless METHODS.include?(method.downcase)

      Motor::NetHttpUtils.public_send(
        method.downcase.to_sym,
        api_config.url.to_s.sub(%r{/?\z}, '/') + path.delete_prefix('/'),
        params,
        headers.merge(api_config.headers),
        body
      )
    end
  end
end
