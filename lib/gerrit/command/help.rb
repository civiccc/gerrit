module Gerrit::Command
  # Displays help documentation.
  class Help < Base
    def execute
      ui.print 'Usage: gerrit [command]'
      ui.newline

      ui.info 'Commands:'

      commands.each do |command|
        ui.print command
      end
    end

    private

    def commands
      Dir[File.join(File.dirname(__FILE__), '*.rb')]
        .map { |path| File.basename(path, '.rb') } - ['base']
    end
  end
end
