# frozen_string_literal: true

require "sequelize_rails/version"
require "sequelize_rails/railtie"
require "sequelize_rails/translation_support"

# Generators
require "rails/generators"
require "sequelize_rails/generators/migration/migration_generator"
require "sequelize_rails/generators/model/model_generator"
require "sequelize_rails/generators/application_record/application_record_generator"

module SequelizeRails

  mattr_accessor :configurations

  # Opens a database connection based on the given configuration name
  def self.connect_to config_name
    config = SequelizeRails.configurations.resolve(config_name).configuration_hash.dup
    config[:adapter] = "sqlite" if config[:adapter] == "sqlite3"
    Sequel.connect config
  end

end
