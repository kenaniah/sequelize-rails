module Sequel
  module Rails
    module Railties
      class LogSubscriber < ActiveSupport::LogSubscriber
        IGNORE_PAYLOAD_NAMES = ["SCHEMA", "EXPLAIN"]

        class_attribute :backtrace_cleaner, default: ActiveSupport::BacktraceCleaner.new

        def self.runtime=(value)
          Thread.current["sequel_sql_runtime"] = value
        end

        def self.runtime
          Thread.current["sequel_sql_runtime"] ||= 0
        end

        def self.count=(value)
          Thread.current["sequel_sql_count"] = value
        end

        def self.count
          Thread.current["sequel_sql_count"] ||= 0
        end

        def self.reset_runtime
          previous = runtime
          self.runtime = 0
          previous
        end

        def self.reset_count
          previous = count
          self.count = 0
          previous
        end

        def sql(event)
          self.class.runtime += event.duration
          self.class.count += 1
          return unless logger.debug?

          payload = event.payload

          return if IGNORE_PAYLOAD_NAMES.include?(payload[:name])

          name = format("%s (%.1fms)", payload[:name], event.duration)
          sql = payload[:sql].squeeze(" ")
          binds = nil

          if payload[:binds]&.any?
            casted_params = type_casted_binds(payload[:type_casted_binds])

            binds = []
            payload[:binds].each_with_index do |attr, i|
              attribute_name = if attr.respond_to?(:name)
                attr.name
              elsif attr.respond_to?(:[]) && attr[i].respond_to?(:name)
                attr[i].name
              end

              filtered_params = filter(attribute_name, casted_params[i])

              binds << render_bind(attr, filtered_params)
            end
            binds = binds.inspect
            binds.prepend("  ")
          end

          name = colorize_payload_name(name, payload[:name])
          sql = color(sql, sql_color(sql), bold: true) if colorize_logging

          debug "  #{name}  #{sql}#{binds}"
        end

        private

        def type_casted_binds(casted_binds)
          casted_binds.respond_to?(:call) ? casted_binds.call : casted_binds
        end

        def render_bind(attr, value)
          case attr
          when ActiveModel::Attribute
            if attr.type.binary? && attr.value
              value = "<#{attr.value_for_database.to_s.bytesize} bytes of binary data>"
            end
          when Array
            attr = attr.first
          else
            attr = nil
          end

          [attr&.name, value]
        end

        def colorize_payload_name(name, payload_name)
          if payload_name.blank? || payload_name == "SQL" # SQL vs Model Load/Exists
            color(name, :white, bold: true)
          else
            color(name, :cyan, bold: true)
          end
        end

        def sql_color(sql)
          case sql
          when /\A\s*rollback/mi
            :red
          when /select .*for update/mi, /\A\s*lock/mi
            :cyan
          when /\A\s*select/i
            :cyan
          when /\A\s*insert/i
            :green
          when /\A\s*update/i
            :yellow
          when /\A\s*delete/i
            :red
          when /transaction\s*\Z/i, /\A\s*begin/i, /\A\s*commit/i
            :blue
          else
            :magenta
          end
        end

        def logger
          ::Rails.application.config.sequel.logger
        end

        def debug(progname = nil, &block)
          return unless super

          if ::Rails.application.config.sequel.verbose_query_logs
            log_query_source
          end
        end

        def log_query_source
          source = extract_query_source_location(caller)

          if source
            logger.debug("        ↳ #{source}")
          end
        end

        def extract_query_source_location(locations)
          backtrace_cleaner.clean(locations.lazy).first
        end

        def filter(name, value)
          ActiveRecord::Base.inspection_filter.filter_param(name, value)
        end
      end
    end
  end
end
