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
end
