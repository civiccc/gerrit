module Gerrit::Command
  # Open console for playing around with helpers exposed to other commands.
  #
  # This is intended to be used to aid in building and debugging commands.
  class Console < Base
    def execute
      require 'pry'
      binding.pry
    end
  end
end
