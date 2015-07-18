module Gerrit
  # Central location of all logic for how exceptions are presented to the user.
  class ErrorHandler
    # Creates exception handler that can display output to user via the given
    # user interface.
    #
    # @param [Gerrit::UI] user interface to print output to
    def initialize(ui)
      @ui = ui
    end

    # Display appropriate output to the user for the given exception, returning
    # a semantic exit status code.
    #
    # @return [Integer] exit status code
    def handle(ex)
      case ex
      when Errors::UsageError
        ui.error ex.message
        CLI::ExitCodes::USAGE
      when Errors::ConfigurationError
        ui.error ex.message
        CLI::ExitCodes::CONFIG
      else
        print_unexpected_exception(ex)
        CLI::ExitCodes::SOFTWARE
      end
    end

    private

    attr_reader :ui

    def print_unexpected_exception(ex)
      ui.bold_error ex.message
      ui.error ex.backtrace.join("\n")
      ui.warning 'Report this bug at ', newline: false
      ui.info BUG_REPORT_URL
      ui.newline
      ui.info 'To help fix this issue, please include:'
      ui.print '- The above stack trace'
      ui.print '- Ruby version: ', newline: false
      ui.info RUBY_VERSION
    end
  end
end
