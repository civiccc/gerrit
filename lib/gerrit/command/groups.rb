module Gerrit::Command
  # List all groups the user can view.
  class Groups < Base
    def execute
      client.groups.each do |group|
        ui.print group
      end
    end
  end
end
