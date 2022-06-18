module SequelizeRails
  module Railties
    class LogSubscriber < ActiveSupport::LogSubscriber
      def self.runtime=(value)
        Thread.current['sequel_sql_runtime'] = value
      end

      def self.runtime
        Thread.current['sequel_sql_runtime'] ||= 0
      end

      def self.count=(value)
        Thread.current['sequel_sql_count'] = value
      end

      def self.count
        Thread.current['sequel_sql_count'] ||= 0
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

        name = format('%s (%.1fms)', payload[:name], event.duration)
        sql  = payload[:sql].squeeze(' ')
        binds = nil

        unless (payload[:binds] || []).empty?
          binds = '  ' + payload[:binds].map do |col, v|
            [col.name, v]
          end.inspect
        end

        if odd?
          name = color(name, :cyan, true)
          sql  = color(sql, nil, true)
        else
          name = color(name, :magenta, true)
        end

        debug "  #{name}  #{sql}#{binds}"
      end

      def odd?
        @odd_or_even = !@odd_or_even
      end

      def logger
        ::Rails.application.config.sequel.logger
      end
    end
  end
end
