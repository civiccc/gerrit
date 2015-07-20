require 'parallel'

module Gerrit
  # A miscellaneous set of utility functions.
  module Utils
    module_function

    # Converts a string containing underscores/hyphens/spaces into CamelCase.
    #
    # @param [String] string
    # @return [String]
    def camel_case(string)
      string.split(/_|-| /)
            .map { |part| part.sub(/^\w/) { |c| c.upcase } }
            .join
    end

    # Returns whether a string appears to be a commit SHA1 hash.
    #
    # @param string [String]
    # @return [Boolean]
    def commit_hash?(string)
      string =~ /^\h{7,40}$/
    end

    # Returns the given {Time} as a human-readable string based on that time
    # relative to the current time.
    #
    # @param time [Time]
    # @return [String]
    def human_time(time)
      date = time.to_date

      if date == Date.today
        time.strftime('%l:%M %p')
      elsif date == Date.today - 1
        'Yesterday'
      elsif date > Date.today - 7
        time.strftime('%A') # Sunday
      elsif date.year == Date.today.year
        time.strftime('%b %e') # Jun 22
      else
        time.strftime('%b %e, %Y') # Jun 22, 2015
      end
    end

    # Executing a block on each item in parallel.
    #
    # @param items [Enumerable]
    # @return [Array]
    def map_in_parallel(items, &block)
      Parallel.map(items, in_threads: Parallel.processor_count) do |item|
        block.call(item)
      end
    end

    # Convert string containing camel case or spaces into snake case.
    #
    # @see stackoverflow.com/questions/1509915/converting-camel-case-to-underscore-case-in-ruby
    #
    # @param [String] string
    # @return [String]
    def snake_case(string)
      string.gsub(/::/, '/')
            .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr('-', '_')
            .downcase
    end
  end
end
