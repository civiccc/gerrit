require 'pathname'
require 'yaml'

module Gerrit
  # Stores runtime configuration for the application.
  #
  # This is intended to define helper methods for accessing configuration so
  # this logic can be shared amongst the various components of the system.
  class Configuration
    # Name of the configuration file.
    FILE_NAME = '.gerrit.yaml'

    class << self
      # Loads appropriate configuration file given the current working
      # directory.
      #
      # @return [Gerrit::Configuration]
      def load_applicable
        current_directory = File.expand_path(Dir.pwd)
        config_file = applicable_config_file(current_directory)

        if config_file
          from_file(config_file)
        else
          raise Errors::ConfigurationMissingError,
                'No configuration file was found'
        end
      end

      # Loads a configuration from a file.
      #
      # @return [Gerrit::Configuration]
      def from_file(config_file)
        options =
          if yaml = YAML.load_file(config_file)
            yaml.to_hash
          else
            {}
          end

        new(options)
      end

      private

      # Returns the first valid configuration file found, starting from the
      # current working directory and ascending to ancestor directories.
      #
      # @param directory [String]
      # @return [String, nil]
      def applicable_config_file(directory)
        Pathname.new(directory)
                .enum_for(:ascend)
                .map { |dir| dir + FILE_NAME }
                .find do |config_file|
          config_file if config_file.exist?
        end
      end
    end

    # Creates a configuration from the given options hash.
    #
    # @param options [Hash]
    def initialize(options)
      @options = options
    end

    # Access the configuration as if it were a hash.
    #
    # @param key [String, Symbol]
    # @return [Array,Hash,Number,String]
    def [](key)
      @options[key.to_s]
    end

    # Compares this configuration with another.
    #
    # @param other [HamlLint::Configuration]
    # @return [true,false] whether the given configuration is equivalent
    def ==(other)
      super || @options == other.instance_variable_get('@options')
    end
  end
end
