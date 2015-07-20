require 'gerrit'

module Gerrit
  # Command line application interface.
  class CLI
    # Set of semantic exit codes we can return.
    #
    # @see http://www.gsp.com/cgi-bin/man.cgi?section=3&topic=sysexits
    module ExitCodes
      OK          = 0   # Successful execution
      USAGE       = 64  # User error (bad command line or invalid input)
      SOFTWARE    = 70  # Internal software error (bug)
      CONFIG      = 78  # Configuration error (invalid file or options)
    end

    # Create a CLI that outputs to the given output destination.
    #
    # @param input [Gerrit::Input]
    # @param output [Gerrit::Output]
    def initialize(input:, output:)
      @ui = UI.new(input, output)
    end

    # Parses the given command-line arguments and executes appropriate logic
    # based on those arguments.
    #
    # @param [Array<String>] arguments
    # @return [Integer] exit status code
    def run(arguments)
      config = Configuration.load_applicable
      run_command(config, arguments)

      ExitCodes::OK
    rescue => ex
      ErrorHandler.new(@ui).handle(ex)
    end

    private

    # Executes the appropriate command given the list of command line arguments.
    #
    # @param config [Gerrit::Configuration]
    # @param ui [Gerrit::UI]
    # @param arguments [Array<String>]
    # @raise [Gerrit::Errors::GerritError] when any exceptional circumstance occurs
    def run_command(config, arguments)
      # Display all open changes by default
      arguments = ['list'] if arguments.empty?

      command_class = find_command(arguments)
      command_class.new(config, @ui, arguments).run
    end

    # Finds the {Command} corresponding to the given set of arguments.
    #
    # @param [Array<String>] arguments
    # @return [Class]
    def find_command(arguments)
      cmd = arguments.first

      begin
        require 'gerrit/command/base'
        require "gerrit/command/#{Utils.snake_case(cmd)}"
      rescue LoadError => ex
        raise Errors::CommandInvalidError,
              "`gerrit #{cmd}` is not a valid command"
      end

      Command.const_get(Utils.camel_case(cmd))
    end
  end
end
