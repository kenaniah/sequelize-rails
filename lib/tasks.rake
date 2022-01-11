# frozen_string_literal: true

# These tasks were copied from activerecord/lib/active_record/railties/databases.rake
# Lines that have been changed will be commented out with the replacement below

require "active_record"
require "active_support/configuration_file"
require "active_support/deprecation"

databases = ActiveRecord::Tasks::DatabaseTasks.setup_initial_database_yaml

ns = :db
db_namespace = namespace ns do
  # Changed: this task was commented out
  # desc "Set the environment value for the database"
  # task "environment:set" => :load_config do
  #   raise ActiveRecord::EnvironmentStorageError unless ActiveRecord::InternalMetadata.enabled?
  #   ActiveRecord::InternalMetadata.create_table
  #   ActiveRecord::InternalMetadata[:environment] = ActiveRecord::Base.connection.migration_context.current_environment
  # end

  # Changed: this task now only checks the loaded environment
  task check_protected_environments: :load_config do
    # Disconnect any potentially-existing Sequel database connections
    Sequel::DATABASES.each(&:disconnect)
    raise "Error: the #{Rails.env} environment is a protected environment." unless Rails.env.test? || Rails.env.development?
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
    db_namespace[:"drop:_unsafe"].invoke
  end

  task "drop:_unsafe": [:load_config] do
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

  ############################################################################
  # end of tasks from activerecord/lib/active_record/railties/databases.rake #
  ############################################################################

  # Initializes a database migrator
  def migrator opts = {}
    if ENV["VERSION"] && ENV["VERSION"].to_i > 0
      opts[:version] = ENV["VERSION"].to_i
    end
    ::Sequel::TimestampMigrator.new(Sequel::DATABASES.first, ActiveRecord::Migrator.migrations_paths.first, opts)
  end

  # Opens a connection to the primary database and loads the migrator
  task connection: [:environment] do
    require "sequel/core"
    Sequel.extension :migration
    SequelizeRails.connect_to :primary
  end

  # desc "Backs up the database from DATABASE_URL or config/database.yml for the current RAILS_ENV"
  # task dump: [] do
  # end

  desc "Migrate the database"
  task migrate: [:connection] do
    migrator.run
  end

  namespace :migrate do
    # desc "Runs the \"down\" method for the last applied migration"
    task down: [:connection] do
      target = (migrator.applied_migrations[-2] || "0_").split("_", 2).first.to_i
      migrator(target: target).run
    end

    # desc "Runs the \"up\" method for the next pending migration"
    task up: [:connection] do
      pending = migrator.migration_tuples.first
      if pending
        target = pending[1].split("_", 2).first.to_i
        migrator(target: target).run
      end
    end

    desc "Rolls back the last migration and re-runs it"
    task redo: [:down, :up]

    desc "Displays the status of the database migrations"
    task status: [:connection] do
      pending = migrator.migration_tuples.count
      if pending == 1
        puts "1 pending migration"
      else
        puts "#{pending} pending migrations"
      end
    end
  end

  desc "Runs #{ns}:setup if the database does not exist or #{ns}:migrate if it does"
  task prepare: [] do
    Rake::Task[:"#{ns}:connection"].invoke
    Rake::Task[:"#{ns}:migrate"].invoke
  rescue Sequel::DatabaseConnectionError
    Rake::Task[:"#{ns}:setup"].invoke
  end

  desc "Runs #{ns}:drop, #{ns}:setup"
  task reset: [:"#{ns}:drop", :"#{ns}:setup"]

  # desc "Restores the backup for database from DATABASE_URL or config/database.yml for the current RAILS_ENV"
  # task restore: [:connection] do
  # end

  desc "Rolls back the last migration"
  task rollback: [:"migrate:down"]

  # namespace :schema do
  #   namespace :cache do
  #     desc "Clears the database schema and indicies caches"
  #     task clear: [] do
  #     end

  #     desc "Creates the database schema and indicies caches"
  #     task dump: [] do
  #     end
  #   end

  #   desc "Creates a backup of just the database's schema"
  #   task dump: [] do
  #   end

  #   desc "Restores the database's schema from backup"
  #   task load: [] do
  #   end
  # end

  # desc "Loads the seed data from db/seeds.rb"
  # task seed: [] do
  # end

  desc "Runs the #{ns}:create, #{ns}:migrate, #{ns}:seed tasks"
  task setup: [:"#{ns}:create", :"#{ns}:migrate", :"#{ns}:seed"]
end
