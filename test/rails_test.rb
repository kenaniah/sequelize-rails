# frozen_string_literal: true

require "test_helper"

class RailsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Sequel::Rails::VERSION
  end

  def test_loads_the_rails_application
    assert_kind_of Dummy::Application, ::Rails.application
    assert_kind_of Rails::Application, Dummy::Application.new
  end

  def test_does_not_load_active_record
    require "open3"
    output, process = Open3.capture2e "rails r \"puts require('active_record'); puts require('active_record');\"", chdir: ::Rails.application.root
    assert_equal "true\nfalse\n", output
    assert_equal 0, process.exitstatus
  end

  def test_loads_rails_console_properly
    require "open3"
    output, process = Open3.capture2e "rails c", chdir: ::Rails.application.root
    refute_equal "", output
    assert_equal 0, process.exitstatus
  end

  def test_loads_db_console_properly
    require "open3"
    output, process = Open3.capture2e "rails db", chdir: ::Rails.application.root
    assert_equal "", output
    assert_equal 0, process.exitstatus
  end

  def test_rake_tasks_do_not_connect_to_db_by_default
    require "open3"
    output, process = Open3.capture2e "rails testing:without_connection", chdir: ::Rails.application.root
    assert_equal "0\n", output
    assert_equal 0, process.exitstatus
  end

  def test_rake_tasks_connect_to_db_when_connection_requested
    require "open3"
    output, process = Open3.capture2e "rails testing:has_connection", chdir: ::Rails.application.root
    assert_equal "1\n", output
    assert_equal 0, process.exitstatus
  end
end
