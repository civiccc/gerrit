module Gerrit::Command
  # Displays a list of all projects the user has permissions to see.
  #
  # This is a light wrapper around `ls-projects` since it will just append any
  # additional arguments to the underlying command.
  class Projects < Base
    def execute
      ui.print client.execute(%w[ls-projects] + arguments[1..-1]),
               newline: false
    end
  end
end
