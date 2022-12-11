# frozen_string_literal: true

module Sequel
  module Rails
    module Generators
      class ModelGenerator < ::Rails::Generators::NamedBase
        source_root File.expand_path("templates", __dir__)
      end
    end
  end
end
