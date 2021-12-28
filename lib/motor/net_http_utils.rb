# frozen_string_literal: true

module Motor
  module NetHttpUtils
    module_function

    def get(url, params = {}, headers = {}, _body = nil)
      request = build_request(Net::HTTP::Get, url, params, headers, nil)

      execute_request(request)
    end

    def post(url, params = {}, headers = {}, body = '')
      request = build_request(Net::HTTP::Post, url, params, headers, body)

      execute_request(request)
    end

    def put(url, params = {}, headers = {}, body = '')
      request = build_request(Net::HTTP::Put, url, params, headers, body)

      execute_request(request)
    end

    def delete(url, params = {}, headers = {}, body = '')
      request = build_request(Net::HTTP::Delete, url, params, headers, body)

      execute_request(request)
    end

    def build_request(method_class, url, params, headers, body)
      uri = URI(url)
      uri.query = params.to_query if params.present?

      request = method_class.new(uri)
      request.body = body if body.present?
      headers.each { |key, value| request[key] = value }

      request
    end

    def execute_request(request)
      uri = request.uri

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.port == 443) do |http|
        http.request(request)
      end
    end
  end
end
