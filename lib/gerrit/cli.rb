require 'gerrit'

module Gerrit
  # Command line application interface.
  class CLI
    # Set of semantic exit codes we can return.
    #
    # @see http://www.gsp.com/cgi-bin/man.cgi?section=3&topic=sysexits
    module ExitCodes
      OK          = 0   # Successful execution
      ERROR       = 1   # Generic error
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

      require 'gerrit/command/base'
      Command::Base.from_arguments(config, @ui, arguments).run
    end
  end
end
