require "sequel"
require "rails"

# Database configuration
require "active_record/connection_handling"
require "active_record/database_configurations"

# Railties
require "action_controller/railtie"
require "sequelize_rails/railties/log_subscriber"
require "sequelize_rails/railties/controller_runtime"

# Load instrumentation before any database connections are established
Sequel.extension :sequel_instrumentation

# Monkey patches
require "sequelize_rails/db_console"

module SequelizeRails
  class Railtie < Rails::Railtie
    ::SequelizeRails::Railties::LogSubscriber.attach_to :sequel
    config.app_generators.orm :sequelize_rails, migration: :sequel_migration
    config.sequel = ActiveSupport::OrderedOptions.new

    initializer "sequel.plugins" do
      ::Sequel::Model.plugin :active_model
    end

    initializer 'sequel.logger' do |app|
      app.config.sequel.logger ||= ::Rails.logger
      app.config.sequel.verbose_query_logs = ::Rails.env.development? if app.config.sequel.verbose_query_logs.nil?
    end

    # https://api.rubyonrails.org/classes/ActiveModel/Translation.html
    initializer "sequel.i18n_support" do
      ::Sequel::Model.send :extend, ::ActiveModel::Translation
      ::Sequel::Model.send :extend, ::SequelizeRails::TranslationSupport
    end

    initializer "sequel.pretty_print" do
      ::Sequel::Model.plugin :pretty_print
    end

    initializer "sequel.configuration" do
      SequelizeRails.configurations = ActiveRecord::DatabaseConfigurations.new Rails.application.config.database_configuration
    end

    initializer "sequel.connection" do
      SequelizeRails.connect_to :primary unless ARGV.any? { |c| c.starts_with? "db:" }
    end

    # Expose database runtime to controller for logging.
    initializer 'sequel.log_runtime' do |_app|
      require 'sequelize_rails/railties/controller_runtime'
      ActionController::Base.send :include, SequelizeRails::Railties::ControllerRuntime
    end

    rake_tasks do
      load File.expand_path("../tasks.rake", __dir__)
    end
  end
end
