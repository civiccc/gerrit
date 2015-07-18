# Collection of errors that can be thrown by the application.
#
# This implements an exception hierarchy which exceptions to be grouped by type
# so the {ExceptionHandler} can display them appropriately.
module Gerrit::Errors
  # Base class for all errors reported by this tool.
  class GerritError < StandardError; end

  # Base class for all errors that are a result of incorrect user usage.
  class UsageError < GerritError; end

  # Base class for all configuration-related errors.
  class ConfigurationError < GerritError; end

  # Raised when a configuration file is not present.
  class ConfigurationMissingError < ConfigurationError; end

  # Raised when a command has failed due to user error.
  class CommandFailedError < UsageError; end

  # Raised when invalid/non-existent command was used.
  class CommandInvalidError < UsageError; end

  # Raised when remote Gerrit command returned a non-zero exit status.
  class GerritCommandFailedError < GerritError; end

  # Raised when run in a directory not part of a valid git repository.
  class InvalidGitRepo < UsageError; end
end
