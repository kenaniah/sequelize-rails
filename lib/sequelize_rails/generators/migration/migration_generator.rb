# frozen_string_literal: true

module SequelizeRails
  module Generators
    class MigrationGenerator < ::Rails::Generators::NamedBase
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def self.next_migration_number _dirname
        Time.now.strftime "%Y%m%d%H%M%S"
      end

      def create_migration_file
        migration_template "migration.rb", "db/migrate/#{file_name}.rb"
      end

    end
  end
end
