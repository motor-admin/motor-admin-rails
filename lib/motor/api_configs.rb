# frozen_string_literal: true

module Motor
  module ApiConfigs
    METHODS = %w[get post put delete].freeze

    DEFAULT_HEADERS = { 'Content-Type' => 'application/json' }.freeze

    InvalidHttpMethod = Class.new(StandardError)

    module_function

    def run(api_config, method: nil, path: nil, body: nil, params: {}, headers: {})
      method ||= 'get'

      raise InvalidHttpMethod unless METHODS.include?(method.downcase)

      Motor::NetHttpUtils.public_send(
        method.downcase.to_sym,
        api_config.url.to_s.sub(%r{/?\z}, '/') + path.delete_prefix('/'),
        params,
        DEFAULT_HEADERS.merge(headers).merge(api_config.headers),
        body&.to_json
      )
    end

    def run_grapql(api_config, query:, variables: {}, headers: {})
      body = {
        query: query,
        variables: variables.merge(form_data: variables)
      }

      Motor::NetHttpUtils.post(
        api_config.url,
        {},
        DEFAULT_HEADERS.merge(headers).merge(api_config.headers),
        body.to_json
      )
    end
  end
end
