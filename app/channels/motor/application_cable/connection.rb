# frozen_string_literal: true

module Motor
  module ApplicationCable
    class Connection < defined?(ActionCable) ? ActionCable::Connection::Base : Object
      identified_by :current_user if defined?(ActionCable)

      def connect
        self.current_user = find_verified_user
      end

      private

      def find_verified_user
        return unless env['warden']

        if env['warden'].respond_to?(:admin_user)
          env['warden'].admin_user
        elsif env['warden'].respond_to?(:admin)
          env['warden'].admin
        else
          env['warden'].user
        end
      end
    end
  end
end
