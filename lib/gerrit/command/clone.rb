module Gerrit::Command
  # Clone a Gerrit project and set up its remotes to push/pull from Gerrit.
  class Clone < Base
    def execute
      unless config[:push_remote]
        raise ConfigurationInvalidError,
              'Missing `push_remote` option in your configuration'
      end

      unless config[:remotes]
        raise ConfigurationInvalidError,
              'Missing `remotes` option in your configuration'
      end

      unless config[:remotes][config[:push_remote]]
        raise ConfigurationInvalidError,
              "Missing `#{config[:push_remote]}` remote in your `remotes` configuration"
      end

      project_name = project

      remote_url = config[:remotes][config[:push_remote]]['url'] % {
        user: config[:user],
        host: config[:host],
        port: config[:port],
        project: project_name,
      }

      clone(remote_url, project_name)
    end

    private

    def clone(remote_url, project)
      p = Pastel.new

      result =
        ui.spinner("Cloning #{p.magenta(project)} from #{p.cyan(remote_url)}...") do
          spawn(%W[git clone #{remote_url}])
        end

      project_dir = File.join(Dir.pwd, project)

      if result.success?
        ui.success("#{project} successfully cloned into #{project_dir}")
        ui.newline
        setup_remotes(project_dir)
      else
        ui.error(result.stdout + result.stderr)
      end
    end

    def project
      if arguments[1]
        arguments[1]
      else
        ui.ask('Enter name of the Gerrit project would you like to clone: ')
          .argument(:required)
          .read_string
      end
    end

    def setup_remotes(repo_directory)
      Dir.chdir(repo_directory) do
        # Remove default remote so we can set up Gerrit remotes
        `git remote rm origin`
        execute_command(%w[setup])
      end
    end
  end
end
