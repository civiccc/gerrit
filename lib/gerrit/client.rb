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
        raise Errors::CommandError,
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
    # @return [Array<String>]
    def members(group, recursive: true)
      flags = []
      flags << '--recursive' if recursive
      execute(%w[ls-members] + ["'#{group}'"] + flags)
    end
  end
end
