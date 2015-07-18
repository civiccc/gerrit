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
