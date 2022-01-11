# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/migration'
require 'active_record'
require 'rails/generators/active_record'
require 'generators/motor/migration'

module Motor
  module Generators
    class UpgradeGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      extend Motor::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      def copy_migration
        has_api_actions = Motor::Resource.all.any? do |resource|
          resource.preferences[:actions]&.any? { |action| action[:action_type] == 'api' }
        end

        unless Motor::ApiConfig.table_exists?
          migration_template 'install_api_configs.rb', 'db/migrate/install_motor_api_configs.rb'
        end

        migration_template 'upgrade_motor_api_actions.rb', 'db/migrate/upgrade_motor_api_actions.rb' if has_api_actions

        if Motor::ApiConfig.table_exists? && !has_api_actions
          puts 'The latest Motor Admin features are already configured'
        else
          puts 'Run `rake db:migrate` to update DB schema'
        end
      end
    end
  end
end
