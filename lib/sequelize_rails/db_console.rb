# Monkey patch to allow Rails DB Console to load properly by loading active_record first
if defined? Rails::DBConsole
  module DBConsoleMonkeyPatch
    def initialize options = {}
      require "active_record"
      super
    end
  end
  Rails::DBConsole.prepend DBConsoleMonkeyPatch
end
