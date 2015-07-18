module Gerrit::Command
  # Displays version information.
  class Version < Base
    def execute
      ui.info Gerrit::VERSION
    end
  end
end
