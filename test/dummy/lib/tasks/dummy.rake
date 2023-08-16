namespace :testing do
  # This task should not connect to the database
  task :without_connection do
    puts Sequel::DATABASES.count # => 0
  end

  # This task should connect to the primary database
  task has_connection: ["db:connection"] do
    puts Sequel::DATABASES.count # => 1
  end
end
