# frozen_string_literal: true

module Sequel
  module Rails
    module Generators
      class ApplicationRecordGenerator < ::Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)

        def create_application_record
          template "application_record.rb", application_record_file_name
        end

        private

        def application_record_file_name
          @application_record_file_name ||=
            if namespaced?
              "app/models/#{namespaced_path}/application_record.rb"
            else
              "app/models/application_record.rb"
            end
        end
      end
    end
  end
end
