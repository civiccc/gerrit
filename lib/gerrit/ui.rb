require 'forwardable'
require 'tty'

module Gerrit
  # Manages all interaction with the user.
  class UI
    extend Forwardable

    def_delegators :@shell, :ask, :confirm

    # Creates a {UI} that mediates between the given input/output streams.
    #
    # @param input [Gerrit::Input]
    # @param output [Gerrit::Output]
    def initialize(input, output)
      @input = input
      @output = output
      @pastel = Pastel.new
      @shell = TTY::Shell.new
    end

    # Get user input, stripping extraneous whitespace.
    #
    # @return [String, nil]
    def user_input
      if input = @input.get
        input.strip
      end
    end

    # Print the specified output.
    #
    # @param output [String]
    # @param newline [Boolean] whether to append a newline
    def print(output, newline: true)
      @output.print(output)
      @output.print("\n") if newline
    end

    # Print output in bold face.
    #
    # @param args [Array]
    # @param kwargs [Hash]
    def bold(*args, **kwargs)
      print(@pastel.bold(*args), **kwargs)
    end

    # Print the specified output in a color indicative of error.
    #
    # @param args [Array]
    # @param kwargs [Hash]
    def error(args, **kwargs)
      print(@pastel.red(*args), **kwargs)
    end

    # Print the specified output in a bold face and color indicative of error.
    #
    # @param args [Array]
    # @param kwargs [Hash]
    def bold_error(*args, **kwargs)
      print(@pastel.bold.red(*args), **kwargs)
    end

    # Print the specified output in a color indicative of success.
    #
    # @param args [Array]
    # @param kwargs [Hash]
    def success(*args, **kwargs)
      print(@pastel.green(*args), **kwargs)
    end

    # Print the specified output in a color indicative of a warning.
    #
    # @param args [Array]
    # @param kwargs [Hash]
    def warning(*args, **kwargs)
      print(@pastel.yellow(*args), **kwargs)
    end

    # Print the specified output in a color indicating information.
    #
    # @param args [Array]
    # @param kwargs [Hash]
    def info(*args, **kwargs)
      print(@pastel.cyan(*args), **kwargs)
    end

    # Print a blank line.
    def newline
      print('')
    end

    # Prints a table.
    #
    # Customize the table by passing a block and operating on the table object
    # passed to that block to add rows and customize its appearance.
    def table(&block)
      t = TTY::Table.new
      block.call(t)
      print(t.render(:unicode))
    end
  end
end
