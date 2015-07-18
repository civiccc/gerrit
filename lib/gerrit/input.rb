module Gerrit
  # Provides interface for collecting input from the user.
  class Input
    # Creates an {Gerrit::Input} wrapping the given IO stream.
    #
    # @param [IO] input the input stream
    def initialize(input)
      @input = input
    end

    # Blocks until a line of input is returned from the input source.
    #
    # @return [String, nil]
    def get
      @input.gets
    end
  end
end
