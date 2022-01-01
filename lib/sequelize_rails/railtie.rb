require "sequel"
require "rails"

# Database configuration
require "active_record/connection_handling"
require "active_record/database_configurations"

module SequelizeRails
  class Railtie < Rails::Railtie
    config.app_generators.orm :sequelize_rails, migration: :sequel_migration

    initializer "sequel.plugins" do
      ::Sequel::Model.plugin :active_model
    end

    # https://api.rubyonrails.org/classes/ActiveModel/Translation.html
    initializer "sequel.i18n_support" do
      ::Sequel::Model.send :extend, ::ActiveModel::Translation
      ::Sequel::Model.send :extend, ::SequelizeRails::TranslationSupport
    end

    initializer "sequel.configuration" do
      SequelizeRails.configurations = ActiveRecord::DatabaseConfigurations.new Rails.application.config.database_configuration
    end

    rake_tasks do
      load File.expand_path("../tasks.rake", __dir__)
    end
  end
end
