require 'active_support/core_ext/module/attr_internal'

module SequelizeRails
  module Railties
    module ControllerRuntime
      extend ActiveSupport::Concern

      protected

      attr_internal :db_runtime

      def process_action(action, *)
        # We also need to reset the runtime before each action
        # because of queries in middleware or in cases we are streaming
        # and it won't be cleaned up by the method below.
        ::SequelizeRails::Railties::LogSubscriber.reset_runtime
        ::SequelizeRails::Railties::LogSubscriber.reset_count
        super
      end

      def cleanup_view_runtime
        db_rt_before_render = ::SequelizeRails::Railties::LogSubscriber.reset_runtime
        self.db_runtime = (db_runtime || 0) + db_rt_before_render
        runtime = super
        db_rt_after_render = ::SequelizeRails::Railties::LogSubscriber.reset_runtime
        self.db_runtime += db_rt_after_render
        runtime - db_rt_after_render
      end

      def append_info_to_payload(payload)
        super
        payload[:db_runtime] = (db_runtime || 0) + ::SequelizeRails::Railties::LogSubscriber.reset_runtime
        payload[:db_query_count] = ::SequelizeRails::Railties::LogSubscriber.count
      end

      module ClassMethods
        def log_process_action(payload)
          messages = super
          messages << format('Database: %.1fms', payload[:db_runtime].to_f) if payload[:db_runtime]
          messages << format('Queries: %d', payload[:db_query_count].to_f) if payload[:db_query_count]
          messages
        end
      end
    end
  end
end
