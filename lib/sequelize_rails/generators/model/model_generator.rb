# frozen_string_literal: true

module SequelizeRails
  module Generators
    class ModelGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)
    end
  end
end
