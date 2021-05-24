# frozen_string_literal: true

module Motor
  module Configs
    module SyncWithRemote
      UnableToSync = Class.new(StandardError)
      ApiNotFound = Class.new(StandardError)

      module_function

      def call(remote_url, api_key)
        url = remote_url.delete_suffix('/') + Motor::Configs::SYNC_API_PATH

        sync_from_remote!(url, api_key)
        sync_to_remote!(url, api_key)
      end

      def sync_from_remote!(remote_url, api_key)
        response = Motor::NetHttpUtils.get(remote_url, {}, { 'X-Authorization' => api_key })

        raise ApiNotFound if response.is_a?(Net::HTTPNotFound)
        raise UnableToSync, [response.message, response.body].join(': ') unless response.is_a?(Net::HTTPSuccess)

        configs_hash = JSON.parse(response.body)

        Motor::Configs::SyncFromHash.call(configs_hash)
      end

      def sync_to_remote!(remote_url, api_key)
        configs_hash = Motor::Configs::BuildConfigsHash.call

        response = Motor::NetHttpUtils.post(
          remote_url,
          {},
          {
            'X-Authorization' => api_key,
            'Content-Type' => 'application/json'
          },
          configs_hash.to_json
        )

        raise ApiNotFound if response.is_a?(Net::HTTPNotFound)
        raise UnableToSync, [response.message, response.body].join(': ') unless response.is_a?(Net::HTTPSuccess)
      end
    end
  end
end
