# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/migration'
require 'active_record'
require 'rails/generators/active_record'
require 'generators/motor/migration'

module Motor
  module Generators
    class InstallProNotesGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      extend Motor::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      def copy_migration
        migration_template 'install_pro_notes.rb', 'db/migrate/install_motor_admin_pro_notes.rb'
      end
    end
  end
end
