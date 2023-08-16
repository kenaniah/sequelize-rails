## [Unreleased]

## [0.4.1] - 2023-08-16

- Adds a `Rails.application.config.sequel.after_connect` hook that is called after each connection is established. This hook can be used to add plugins and extensions to the database connection once established.

## [0.4.0] - 2023-08-16

- Rake tasks will no longer attempt a database connection by default
- A new `db:connection` rake task has been added for explicitly connecting to the primary database
