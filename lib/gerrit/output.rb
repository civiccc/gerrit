module Gerrit
  # Encapsulates all communication to an output source.
  class Output
    # Creates a {Gerrit::Output} which displays nothing.
    #
    # @return [Gerrit::Output]
    def self.silent
      new(File.open('/dev/null', 'w'))
    end

    # Creates a new {Gerrit::Output} instance.
    #
    # @param stream [IO] the output destination stream.
    def initialize(stream)
      @output_stream = stream
    end

    # Print the specified output.
    #
    # @param [String] output the output to display
    def print(output)
      @output_stream.print(output)
    end
  end
end
