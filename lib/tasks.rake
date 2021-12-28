ns = :db
namespace ns do

  desc "Creates the database from DATABASE_URL or config/database.yml for the current RAILS_ENV"
  task create: [] do
    puts "Running create task"
  end

  desc "Drops the database from DATABASE_URL or config/database.yml for the current RAILS_ENV"
  task drop: [] do
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
  task reset: [] do
  end

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
