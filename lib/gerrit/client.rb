require 'json'

module Gerrit
  # Client for executing commands against the Gerrit server.
  class Client
    # Create a client using the given configuration settings.
    #
    # @param config [Gerrit::Configuration]
    def initialize(config)
      @config = config
    end

    # Executes a command against the Gerrit server, returning the output.
    #
    # @param command [Array<String>]
    # @return [String]
    def execute(command)
      user = @config[:user]
      host = @config[:host]
      port = @config[:port]
      ssh_cmd = %W[ssh -p #{port} #{user}@#{host} gerrit] + command

      result = Subprocess.spawn(ssh_cmd)
      unless result.success?
        raise Errors::GerritCommandFailedError,
              "Command `#{ssh_cmd.join(' ')}` failed:\n" \
              "STATUS: #{result.status}\n" \
              "STDOUT: #{result.stdout.inspect}\n" \
              "STDERR: #{result.stderr.inspect}\n"
      end

      result.stdout
    end

    # Returns all groups visible to the user.
    #
    # @return [Array<String>]
    def groups
      execute(%w[ls-groups]).split("\n")
    end

    # Returns members associated with a group.
    #
    # @param group [String] full name of the group
    # @param recursive [Boolean] whether to include members of sub-groups.
    # @return [Array<Hash>]
    def group_members(group, recursive: true)
      flags = []
      flags << '--recursive' if recursive

      rows = execute(%w[ls-members] + ["'#{group}'"] + flags).split("\n")[1..-1]

      rows.map do |row|
        id, username, full_name, email = row.split("\t")
        { id: id, username: username, full_name: full_name, email: email }
      end
    end

    # Returns basic information about a change.
    def change(change_id_or_number)
      rows = execute(%W[query --format=JSON
                        --current-patch-set
                        change:#{change_id_or_number}]).split("\n")[0..-2]

      if rows.empty?
        raise Errors::CommandFailedError,
              "No change matches the id '#{change_id_or_number}'"
      else
        JSON.parse(rows.first)
      end
    end

    def query_changes(query)
      rows = execute(%W[query
                        --format=JSON
                        --current-patch-set
                        --submit-records] + [query]).split("\n")[0..-2]

      rows.map { |row| JSON.parse(row) }
    end

    # Returns a list of all users to include in the default search scope.
    #
    # Gerrit doesn't actually have an endpoint to return all visible users, so
    # we do the next best thing which is to get users for all groups the user is
    # a part of, which for all practical purposes is probably good enough.
    #
    # Set the `user_search_groups` configuration option to speed this up,
    # ideally to just one group so we don't have to make parallel calls.
    def users
      search_groups = Array(@config.fetch(:user_search_groups, groups))

      Utils.map_in_parallel(search_groups) do |group|
        group_members(group).map{ |user| user[:username] }
      end.flatten.uniq
    end
  end
end
