module Gerrit::Command
  # Lists members of a group.
  #
  # This allows you to list the members of a group by regex.
  class Members < Base
    def execute
      ui.print client.members(find_group), newline: false
    end

    private

    def find_group
      matches = client.groups.grep(/#{search_term}/i)

      if matches.empty?
        ui.error 'No groups match the given name/regex'
        raise Gerrit::Errors::CommandFailedError
      elsif matches.size >= 2
        ui.warning 'Multiple groups match the given regex:'
        matches.each do |group|
          ui.print group
        end
        raise Gerrit::Errors::CommandFailedError
      end

      matches[0]
    end

    def search_term
      if arguments[1]
        arguments[1]
      else
        ui.ask('Enter group name or regex').argument(:required).read_string
      end
    end
  end
end
