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
end
