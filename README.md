# sequelize-rails

This gem provides support for using [Sequel](https://sequel.jeremyevans.net/) as an ORM for Rails applications by providing features that are similar to ActiveRecord's integration with Rails. It is an alternative to [sequel-rails](https://github.com/TalentBox/sequel-rails).

## Using sequelize-rails

Add this line to your application's Gemfile:

```ruby
gem 'sequelize-rails'
```

And then execute:

    $ bundle install

If you are looking to replace ActiveRecord entirely, you may need to either generate your Rails app using `--skip-active-record` or manually remove references to ActiveRecord in your `Gemfile`,  `config/application.rb`, and `config/environments/*.rb` files.

## Features provided by `sequelize-rails`

**Database Management**

 - [x] [Connectivity](#database-connectivity) via `config/database.yml`
 - [x] [Console](#database-console) via `rails db`
 - [x] [Migrations](https://sequel.jeremyevans.net/rdoc/files/doc/migration_rdoc.html) via `Sequel::Migration`
 - [x] [Rake tasks](#database-rake-tasks) via `rails db:*`

### Database Connectivity

This gem will automatically use your application's `config/database.yml` file to configure the available database connection(s).

#### Primary Connection

A connection to the "primary" database is automatically established when the application is loaded. This connection will by used by default for all model classes that do not specify a different connection.

The primary connection can be referenced directly via:

```ruby
Sequel::DATABASES.first # instead of ActiveRecord::Base.connection
```

A common convention within applications that use Sequel is to store the primary connection in the `DB` constant, which can be easily done within an initializer file via the following:

```ruby
# config/initializers/sequel.rb
DB = Sequel::DATABASES.first unless defined?(DB)
```

#### Additional Connections

Additional connections can be configured in your `config/database.yml` file by adding additional entries to the `databases` key. For example:

```yaml
# config/database.yml

# ... snip ...

production:
  <<: *default
  database: <%= ENV["DATABASE_URL"] %>

my_replica:
  <<: *default
  database: <%= ENV["REPLICA_DATABASE_URL"] %>

```

Additional connections can be retrieved via `Sequel::Rails.connect_to`, such as within the example below:


```ruby
replica_connection = Sequel::Rails.connect_to :my_replica
```

### Database Console

You can connect directly to your database via the `rails db` command. This command is similar to the `rails console` command, but instead of loading your application, it will connect directly to the database.

```bash
# connects to the primary database
$ rails db

# connects to the database of the test environment
$ rails db -e test
```

Please note that only the `-e` flag is supported at this time. Other flags such as `--database` are not supported.

### Database Rake Tasks

This gem provides a set of rake tasks that are similar to the ActiveRecord tasks. These tasks can be used to create, drop, migrate, and seed your database.

| Task | Description |
| --- | --- |
| `rails db:create` | Creates the database from `DATABASE_URL` or `config/database.yml` for the current `RAILS_ENV` (use `db:create:all` to create all databases in the config). |
| `rails db:drop` | Drops the database from `DATABASE_URL` or `config/database.yml` for the current `RAILS_ENV` (use `db:drop:all` to drop all databases in the config). |
| `rails db:migrate` | Runs database migrations |
| `rails db:migrate:redo` | Rolls back the last migration and re-runs it |
| `rails db:migrate:status` | Displays the status of the database migrations |
| `rails db:prepare` | Runs `db:setup` if the database does not exist or `db:migrate` if it does |
| `rails db:reset` | Runs `db:drop`, `db:setup` |
| `rails db:rollback` | Rolls back the last migration |
| `rails db:setup` | Runs the `db:create`, `db:migrate`, `db:seed` tasks |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kenaniah/sequelize-rails.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Roadmap

 - [ ] Support `rails console --sandbox` (auto rollback all transactions)
 - [ ] Support logging
 - [ ] Support db rake tasks
 - [ ] Support reloading (disconnect all connections)
 - [ ] Support ActiveRecord plugins / conventions (shims)
 - [ ] Support PostgreSQL custom format for dump & restore
 - [ ] Support generators (including orm)
 - [ ] Support migration generator (and parsed attributes)
