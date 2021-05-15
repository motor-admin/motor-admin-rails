# frozen_string_literal: true

module Motor
  module Configs
    class SyncMiddleware
      KeyNotSpecified = Class.new(StandardError)
      NotAuthenticated = Class.new(StandardError)

      def initialize(app)
        @app = app
      end

      def call(env)
        if env['PATH_INFO'] == Motor::Configs::SYNC_API_PATH
          authenticate!(env['HTTP_X_AUTHORIZATION'])

          case env['REQUEST_METHOD']
          when 'GET'
            respond_with_configs
          when 'POST'
            input = env['rack.input']
            input.rewind
            sync_configs(input.read)
          else
            @app.call(env)
          end
        else
          @app.call(env)
        end
      rescue NotAuthenticated
        [403, {}, ['Invalid synchronization API key']]
      rescue KeyNotSpecified
        [404, {}, ['Set `MOTOR_SYNC_API_KEY` environment variable in order to sync configs']]
      end

      private

      def authenticate!(token)
        raise KeyNotSpecified if Motor::Configs::SYNC_ACCESS_KEY.blank?
        raise NotAuthenticated if token.blank?

        is_token_valid =
          ActiveSupport::SecurityUtils.secure_compare(
            Digest::SHA256.hexdigest(token),
            Digest::SHA256.hexdigest(Motor::Configs::SYNC_ACCESS_KEY)
          )

        raise NotAuthenticated unless is_token_valid
      end

      def respond_with_configs
        [
          200,
          { 'Content-Type' => 'application/json' },
          [Motor::Configs::BuildConfigsHash.call.to_json]
        ]
      rescue StandardError => e
        [500, {}, [e.message]]
      end

      def sync_configs(body)
        configs_hash = JSON.parse(body)

        Motor::Configs::SyncFromHash.call(configs_hash)

        [200, {}, []]
      rescue StandardError => e
        [500, {}, [e.message]]
      end
    end
  end
end
