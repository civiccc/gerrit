require 'pathname'

module Gerrit
  # Exposes information about the current git repository.
  class Repo
    # @param config [Gerrit::Configuration]
    def initialize(config)
      @config = config
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
      @config[:project] || File.basename(root)
    end

    # Returns the Gerrit remote URL for this repo.
    def remote_url
      "ssh://#{@config[:user]}@#{@config[:host]}:#{@config[:port]}/#{project}"
    end

    # Returns the refspec for the given change number.
    def ref_for_change(change_number)
      # Gerrit takes the last two digits of the change number to nest under a
      # directory with that name so they don't exceed the per-directory file limit
      prefix = change_number.rjust(2, '0').to_s[-2..-1]

      "refs/changes/#{prefix}/#{change_number}"
    end
  end
end
