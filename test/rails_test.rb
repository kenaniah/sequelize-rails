# frozen_string_literal: true

require "test_helper"

class RailsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::SequelizeRails::VERSION
  end

  def test_loads_the_rails_application
    assert_kind_of Dummy::Application, Rails.application
    assert_kind_of Rails::Application, Dummy::Application.new
  end

  def test_loads_db_console_properly
    require "open3"
    output, process = Open3.capture2e "rails db", chdir: Rails.application.root
    assert_equal "", output
    assert process.success?
    assert_equal 0, process.exitstatus
  end
end
