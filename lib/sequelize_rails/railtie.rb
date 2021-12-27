require "sequel"
require "rails"

module SequelizeRails
  class Railtie < Rails::Railtie
    config.app_generators.orm :sequel, migration: :sequel_migration

    # https://api.rubyonrails.org/classes/ActiveModel/Translation.html
    initializer "sequel.i18n_support" do
      ::Sequel::Model.plugin :active_model
      ::Sequel::Model.send :extend, ::ActiveModel::Translation
      ::Sequel::Model.send :extend, ::SequelizeRails::TranslationSupport
    end
  end
end
