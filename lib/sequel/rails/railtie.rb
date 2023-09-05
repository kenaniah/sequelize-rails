require "sequel"
require "rails"

# Database configuration
require "active_record/connection_handling"
require "active_record/database_configurations"

# Railties
require "action_controller/railtie"
require "sequel/rails/railties/log_subscriber"
require "sequel/rails/railties/controller_runtime"

# Load instrumentation (before any database connections are established)
Sequel.extension :sequel_instrumentation

# Monkey patches
require "sequel/rails/db_console"

module Sequel
  module Rails
    class Railtie < ::Rails::Railtie
      # Log subscriber
      ::Sequel::Rails::Railties::LogSubscriber.attach_to :sequel
      ::Sequel::Rails::Railties::LogSubscriber.backtrace_cleaner.add_filter { |line| line.gsub(::Rails.root.to_s + File::SEPARATOR, "") }

      # Config initialization
      config.app_generators.orm :sequel
      config.sequel = ActiveSupport::OrderedOptions.new

      initializer "sequel.plugins" do
        ::Sequel::Model.plugin :active_model
      end

      initializer "sequel.logger" do |app|
        app.config.sequel.logger ||= ::Rails.logger
        app.config.sequel.verbose_query_logs = ::Rails.env.development? if app.config.sequel.verbose_query_logs.nil?
      end

      # https://api.rubyonrails.org/classes/ActiveModel/Translation.html
      initializer "sequel.i18n_support" do
        ::Sequel::Model.send :extend, ::ActiveModel::Translation
        ::Sequel::Model.send :extend, ::Sequel::Rails::TranslationSupport
      end

      initializer "sequel.pretty_print" do
        ::Sequel::Model.plugin :pretty_print
      end

      initializer "sequel.configuration" do
        ::Sequel::Rails.configurations = ActiveRecord::DatabaseConfigurations.new ::Rails.application.config.database_configuration
      end

      initializer "sequel.connection" do
        in_rake = Rails.const_defined?(:Rake) && Rake.application.top_level_tasks.length > 0
        ::Sequel::Rails.connect_to :primary unless in_rake
      end

      # Expose database runtime to controller for logging.
      initializer "sequel.log_runtime" do |_app|
        require "sequel/rails/railties/controller_runtime"
        ActionController::Base.send :include, ::Sequel::Rails::Railties::ControllerRuntime
      end

      rake_tasks do
        load File.expand_path("../tasks.rake", __dir__)
      end

      generators do
        require "sequel/generators/application_record_generator"
        require "sequel/generators/migration_generator"
        require "sequel/generators/model_generator"
      end
    end
  end
end
