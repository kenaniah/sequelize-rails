# frozen_string_literal: true

require "sequelize_rails/version"
require "sequelize_rails/railtie"
require "sequelize_rails/translation_support"

# Plugins
require "sequel/plugins/pretty_print"

# Generators
require "rails/generators"
require "sequelize_rails/generators/migration/migration_generator"
require "sequelize_rails/generators/model/model_generator"
require "sequelize_rails/generators/application_record/application_record_generator"

module SequelizeRails
  mattr_accessor :configurations

  # Opens a database connection based on the given configuration name
  def self.connect_to config_name, opts = {}
    config = SequelizeRails.configurations.resolve(config_name).configuration_hash.dup
    config[:adapter] = "sqlite" if config[:adapter] == "sqlite3"
    config[:max_connections] ||= config.delete(:pool) if config[:pool]
    config[:pool_timeout] ||= config.delete(:timeout) / 1000 if config[:timeout]
    Dir.chdir Rails.root do
      Sequel.connect config, opts
    end
  end
end
