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

      ui.info "Cloning #{p.magenta(project)} from #{p.cyan(remote_url)}..."
      if system("git clone #{remote_url}")
        project_dir = File.join(Dir.pwd, project)
        install_change_id_hook(project_dir)

        ui.success("#{project} successfully cloned into #{project_dir}")
        ui.newline

        setup_remotes(project_dir)
      else
        ui.error "Unable to clone #{project}!"
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

    def install_change_id_hook(repo_directory)
      Dir.chdir(repo_directory) do
        commit_msg_hook_path = File.join(repo.git_dir, 'hooks', 'commit-msg')

        if File.exist?(commit_msg_hook_path)
          ui.warning('Skipping install of Gerrit Change ID commit-msg hook ' \
                     "as there is already a #{commit_msg_hook_path} file present")
          return
        end

        result = ui.spinner('Downloading Gerrit Change ID commit-msg hook...') do
          spawn(%W[scp -P #{config[:port]}
                   #{config[:user]}@#{config[:host]}:hooks/commit-msg
                   #{commit_msg_hook_path}])
        end

        if result.success?
          ui.success('Installed Gerrit Change ID commit-msg hook')
        else
          ui.warning('Unable to install Gerrit Change ID commit-msg hook:')
          ui.error(result.stdout + result.stderr)
          ui.warning("You won't be able to push your commits to Gerrit without this hook")
        end
      end
    end
  end
end
