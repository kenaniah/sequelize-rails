# frozen_string_literal: true

# These tasks were copied from activerecord/lib/active_record/railties/databases.rake
# Lines that have been changed will be commented out with the replacement below

require "active_record"
require "active_support/configuration_file"
require "active_support/deprecation"

databases = ActiveRecord::Tasks::DatabaseTasks.setup_initial_database_yaml

ns = :db
db_namespace = namespace ns do
  desc "Set the environment value for the database"
  task "environment:set" => :load_config do
    raise ActiveRecord::EnvironmentStorageError unless ActiveRecord::InternalMetadata.enabled?
    ActiveRecord::InternalMetadata.create_table
    ActiveRecord::InternalMetadata[:environment] = ActiveRecord::Base.connection.migration_context.current_environment
  end

  task check_protected_environments: :load_config do
    ActiveRecord::Tasks::DatabaseTasks.check_protected_environments!
  end

  task load_config: :environment do
    if ActiveRecord::Base.configurations.empty?
      # Changed: the active_record railtie may not be loaded, so we need to load the database configuration directly
      # ActiveRecord::Base.configurations = ActiveRecord::Tasks::DatabaseTasks.database_configuration
      ActiveRecord::Base.configurations = Rails.application.config.database_configuration
      # This line was also added
      ActiveRecord::Base.establish_connection
    end

    ActiveRecord::Migrator.migrations_paths = ActiveRecord::Tasks::DatabaseTasks.migrations_paths
  end

  namespace :create do
    task all: :load_config do
      ActiveRecord::Tasks::DatabaseTasks.create_all
    end

    ActiveRecord::Tasks::DatabaseTasks.for_each(databases) do |name|
      desc "Create #{name} database for current environment"
      task name => :load_config do
        db_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: name)
        ActiveRecord::Tasks::DatabaseTasks.create(db_config)
      end
    end
  end

  desc "Creates the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (use db:create:all to create all databases in the config). Without RAILS_ENV or when RAILS_ENV is development, it defaults to creating the development and test databases, except when DATABASE_URL is present."
  task create: [:load_config] do
    ActiveRecord::Tasks::DatabaseTasks.create_current
  end

  namespace :drop do
    task all: [:load_config, :check_protected_environments] do
      ActiveRecord::Tasks::DatabaseTasks.drop_all
    end

    ActiveRecord::Tasks::DatabaseTasks.for_each(databases) do |name|
      desc "Drop #{name} database for current environment"
      task name => [:load_config, :check_protected_environments] do
        db_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: name)
        ActiveRecord::Tasks::DatabaseTasks.drop(db_config)
      end
    end
  end

  desc "Drops the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (use db:drop:all to drop all databases in the config). Without RAILS_ENV or when RAILS_ENV is development, it defaults to dropping the development and test databases, except when DATABASE_URL is present."
  task drop: [:load_config, :check_protected_environments] do
    db_namespace["drop:_unsafe"].invoke
  end

  task "drop:_unsafe" => [:load_config] do
    ActiveRecord::Tasks::DatabaseTasks.drop_current
  end

  namespace :purge do
    task all: [:load_config, :check_protected_environments] do
      ActiveRecord::Tasks::DatabaseTasks.purge_all
    end
  end

  # desc "Truncates tables of each database for current environment"
  task truncate_all: [:load_config, :check_protected_environments] do
    ActiveRecord::Tasks::DatabaseTasks.truncate_all
  end

  # desc "Empty the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (use db:purge:all to purge all databases in the config). Without RAILS_ENV it defaults to purging the development and test databases, except when DATABASE_URL is present."
  task purge: [:load_config, :check_protected_environments] do
    ActiveRecord::Tasks::DatabaseTasks.purge_current
  end

  desc "Backs up the databse from DATABASE_URL or config/database.yml for the current RAILS_ENV"
  task dump: [] do
  end

  desc "Migrate the database"
  task migrate: [] do
  end

  namespace :migrate do
    desc "Runs the \"down\" method for a given migration"
    task down: [] do
    end

    desc "Runs the \"up\" method for a given migration"
    task up: [] do
    end

    desc "Rolls back the last migration and re-runs it"
    task redo: [] do
    end

    desc "Displays the status of the database migrations"
    task status: [] do
    end
  end

  desc "Runs #{ns}:setup if the database does not exist or #{ns}:migrate if it does"
  task prepare: [] do
  end

  desc "Runs #{ns}:drop and then #{ns}:setup"
  task reset: ["#{ns}:drop", "#{ns}:setup"]

  desc "Restores the backup for database from DATABASE_URL or config/database.yml for the current RAILS_ENV"
  task restore: [] do
  end

  desc "Rolls back the last migration"
  task rollback: [] do
  end

  namespace :schema do
    namespace :cache do
      desc "Clears the database schema and indicies caches"
      task clear: [] do
      end

      desc "Creates the database schema and indicies caches"
      task dump: [] do
      end
    end

    desc "Creates a backup of just the database's schema"
    task dump: [] do
    end

    desc "Restores the database's schema from backup"
    task load: [] do
    end
  end

  desc "Loads the seed data from db/seeds.rb"
  task seed: [] do
  end

  desc "Runs the #{ns}:create, #{ns}:migrate, #{ns}:seed tasks"
  task setup: [] do
  end
end
