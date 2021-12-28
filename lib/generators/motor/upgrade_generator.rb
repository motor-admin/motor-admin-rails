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
        if Motor::ApiConfig.table_exists?
          puts 'The latest Motor Admin features are already configured'
        else
          migration_template 'install_api_configs.rb', 'db/migrate/install_motor_api_configs.rb'

          puts 'Run `rake db:migrate` to update DB schema'
        end
      end
    end
  end
end
