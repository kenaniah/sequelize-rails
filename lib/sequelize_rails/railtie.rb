require "sequel"
require "rails"

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

    rake_tasks do
      load File.expand_path("../tasks.rake", __dir__)
    end
  end
end
