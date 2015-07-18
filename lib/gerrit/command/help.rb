module Gerrit::Command
  # Displays help documentation.
  class Help < Base
    def execute
      ui.print 'Usage: gerrit [command]'
    end
  end
end
