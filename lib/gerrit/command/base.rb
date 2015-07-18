require 'gerrit/client'

module Gerrit::Command
  # Abstract base class of all commands.
  #
  # @abstract
  class Base
    # @param config [Gerrit::Configuration]
    # @param ui [Gerrit::UI]
    # @param arguments [Array<String>]
    def initialize(config, ui, arguments)
      @config = config
      @ui = ui
      @arguments = arguments
    end

    # Parses arguments and executes the command.
    def run
      # TODO: include a parse step here and remove duplicate parsing code from
      # individual commands
      execute
    end

    # Executes the command given the previously-parsed arguments.
    def execute
      raise NotImplementedError, 'Define `execute` in Command subclass'
    end

    private

    # @return [Array<String>]
    attr_reader :arguments

    # @return [Gerrit::Configuration]
    attr_reader :config

    # @return [Gerrit::UI]
    attr_reader :ui

    # Returns a client for making requests to the Gerrit server.
    #
    # @return [Gerrit::Client]
    def client
      @client ||= Gerrit::Client.new(@config)
    end

    # Returns information about this repository.
    #
    # @return [Gerrit::Repo]
    def repo
      @repo ||= Gerrit::Repo.new(@config)
    end

    # Execute a process and return the result including status and output.
    def spawn(args)
      Subprocess.spawn(args)
    end
  end
end
