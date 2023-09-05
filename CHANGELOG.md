## [Unreleased]

- Adjusts the description of the `db:rollback` rake task

## [0.6.2] - 2023-09-05

- Updates the Sequel migration to use Sequel's preferred transaction semantics

## [0.6.1] - 2023-09-04

- Migrations now generate SQL files by default

## [0.6.0] - 2023-09-04

- Adds migration generator

## [0.5.0] - 2023-09-04

- Adds the `db:seed` rake task for running seed files
- Stubs the `db:schema:load` rake task and adds it as a step in `db:setup`
- Stubs the `db:schema:dump` rake task

## [0.4.1] - 2023-08-16

- Adds a `Rails.application.config.sequel.after_connect` hook that is called after each connection is established. This hook can be used to add plugins and extensions to the database connection once established.

## [0.4.0] - 2023-08-16

- Rake tasks will no longer attempt a database connection by default
- A new `db:connection` rake task has been added for explicitly connecting to the primary database
