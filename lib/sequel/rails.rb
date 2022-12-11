# frozen_string_literal: true

require "sequel/rails/version"
require "sequel/rails/railtie"
require "sequel/rails/translation_support"

# Plugins
require "sequel/plugins/pretty_print"

# Generators
require "rails/generators"
require "sequel/rails/generators/migration/migration_generator"
require "sequel/rails/generators/model/model_generator"
require "sequel/rails/generators/application_record/application_record_generator"

module Sequel
  module Rails
    mattr_accessor :configurations

    # Opens a database connection based on the given configuration name
    def self.connect_to config_name, opts = {}
      config = self.configurations.resolve(config_name).configuration_hash.dup
      config[:adapter] = "sqlite" if config[:adapter] == "sqlite3"
      config[:max_connections] ||= config.delete(:pool) if config[:pool]
      config[:pool_timeout] ||= config.delete(:timeout) / 1000 if config[:timeout]
      Dir.chdir ::Rails.root do
        ::Sequel.connect config, opts
      end
    end
  end
end