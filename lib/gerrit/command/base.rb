require 'gerrit/client'

module Gerrit::Command
  # Abstract base class of all commands.
  #
  # @abstract
  class Base
    include Gerrit::Utils

    # Create a command from a list of arguments.
    #
    # @param config [Gerrit::Configuration]
    # @param ui [Gerrit::UI]
    # @param arguments [Array<String>]
    # @return [Gerrit::Command::Base] appropriate command for the given
    #   arguments
    def self.from_arguments(config, ui, arguments)
      cmd = arguments.first

      begin
        require "gerrit/command/#{Gerrit::Utils.snake_case(cmd)}"
      rescue LoadError => ex
        raise Gerrit::Errors::CommandInvalidError,
              "`gerrit #{cmd}` is not a valid command"
      end

      Gerrit::Command.const_get(Gerrit::Utils.camel_case(cmd)).new(config, ui, arguments)
    end

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

    # Executes another command from the same context as this command.
    #
    # @param command_arguments [Array<String>]
    def execute_command(command_arguments)
      self.class.from_arguments(config, ui, command_arguments).execute
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
    #
    # @param args [Array<String>]
    # @return [#status, #stdout, #stderr]
    def spawn(args)
      Gerrit::Subprocess.spawn(args)
    end
  end
end
