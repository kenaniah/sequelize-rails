# frozen_string_literal: true

require "test_helper"

# Launch the application
Rails.application.initialize!

class ModelTest < Minitest::Test
  # Test active_model compatibility
  include ActiveModel::Lint::Tests
  def model
    Sequel::Model.new
  end
end
