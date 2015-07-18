require 'pathname'

module Gerrit
  # Exposes information about the current git repository.
  class Repo
    # @param config [Gerrit::Configuration]
    def initialize(config)
      @config = config
    end

    # Returns the name of the currently checked-out branch or the branch the
    # specified ref is on.
    #
    # Returns nil if it is detached.
    #
    # @return [String, nil]
    def branch(ref = 'HEAD')
      name = `git branch`.split("\n").grep(/^\* /).first[/\w+/]
      # Check if detached head
      name.start_with?('(') ? nil : name
    end

    # Returns the absolute path to the root of the current repository the
    # current working directory resides within.
    #
    # @return [String]
    # @raise [Gerrit::Errors::InvalidGitRepoError] if the current directory
    #   doesn't reside within a git repository
    def root
      @root ||=
        begin
          git_dir = Pathname.new(File.expand_path('.'))
                            .enum_for(:ascend)
                            .find do |path|
            (path + '.git').exist?
          end

          unless git_dir
            raise Errors::InvalidGitRepoError, 'no .git directory found'
          end

          git_dir.to_s
        end
    end

    # Returns an absolute path to the .git directory for a repo.
    #
    # @return [String]
    def git_dir
      @git_dir ||=
        begin
          git_dir = File.expand_path('.git', root)

          # .git could also be a file that contains the location of the git directory
          unless File.directory?(git_dir)
            git_dir = File.read(git_dir)[/^gitdir: (.*)$/, 1]

            # Resolve relative paths
            unless git_dir.start_with?('/')
              git_dir = File.expand_path(git_dir, repo_dir)
            end
          end

          git_dir
        end
    end

    # Returns the project name for this repo.
    #
    # Uses the project name specified by the configuration, otherwise just uses
    # the repo root directory.
    #
    # @return [String]
    def project
      if url = remote_url
        File.basename(url[/\/[^\/]+$/], '.git')
      else
        # Otherwise just use the name of this repository
        File.basename(root)
      end
      #
    end

    # Returns all remotes this repository has configured.
    #
    # @return [Hash] hash of remote names mapping to their URLs
    def remotes
      Hash[
        `git config --get-regexp '^remote\..+\.url$'`.split("\n").map do |line|
          match = line.match(/^remote\.(?<name>\S+)\.url\s+(?<url>.*)/)
          [match[:name], match[:url]]
        end
      ]
    end

    # Returns the Gerrit remote URL for this repo.
    def remote_url
      unless push_remote = @config[:push_remote]
        raise Errors::ConfigurationInvalidError,
              'You must specify the `push_remote` option in your configuration.'
      end

      unless url = remotes[push_remote]
        raise Errors::ConfigurationInvalidError,
              "The '#{push_remote}' `push_remote` specified in your " \
              'configuration is not a remote in this repository. ' \
              'Have you run `gerrit setup`?'
      end

      url
    end
  end
end
