# frozen_string_literal: true

module SequelizeRails
  module Generators
    class MigrationGenerator < ::Rails::Generators::NamedBase
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

      def self.next_migration_number _dirname
        Time.now.strftime "%Y%m%d%H%M%S"
      end

      def create_migration_file
        migration_template "migration.rb.erb", "db/migrate/#{file_name}.rb"
      end
    end
  end
end
