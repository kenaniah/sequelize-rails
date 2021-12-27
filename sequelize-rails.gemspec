# frozen_string_literal: true

require_relative "lib/sequelize_rails/version"

Gem::Specification.new do |spec|
  spec.name = "sequelize-rails"
  spec.version = ::SequelizeRails::VERSION
  spec.authors = ["Kenaniah Cerny"]
  spec.email = ["kenaniah@gmail.com"]

  spec.summary = "A gem for using Sequel with Rails natively."
  spec.description = "This gem provides the railtie that allows Sequel to hook into Rails as an alternative or supplement to ActiveRecord."
  spec.homepage = "https://github.com/kenaniah/sequelize-rails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org/"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + "/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 6.0.0"
  spec.add_dependency "sequel", ">= 5.0.0"

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "pry"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
