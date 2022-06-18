module Sequel
  module Extensions
    module SequelInstrumentation
      def log_connection_yield(sql, conn, args = nil)
        ActiveSupport::Notifications.instrument "sql.sequel", sql: sql, conn: conn, binds: args do
          super
        end
      end
    end
  end
  Database.register_extension(:sequel_instrumentation, Extensions::SequelInstrumentation)
  Database.extension(:sequel_instrumentation)
end
