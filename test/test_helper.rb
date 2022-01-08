# frozen_string_literal: true

require "pry"

# Configure minitest
require "minitest/reporters"
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]

require "minitest/autorun"

# Load the rails application
ENV["RAILS_ROOT"] ||= File.dirname(__FILE__) + "/dummy"
require_relative "dummy/config/application"
