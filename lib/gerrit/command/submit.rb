module Gerrit::Command
  # Display a list of submittable changes and ask the user which to submit.
  class Submit < Base
    # Default search query that assumes a change is submittable if there is at
    # least one +1 for both Code-Review and Verified labels and no -1s.
    DEFAULT_SEARCH_QUERY = %w[
      is:open
      label:Code-Review+1
      label:Verified+1
      NOT label:Code-Review-1
      NOT label:Verified-1
    ].join(' ')

    def execute
      list_query = config.fetch('submittable_changes', DEFAULT_SEARCH_QUERY)
      execute_command(['list', list_query])

      # This will return a cached result from Command::List
      changes = Gerrit::Command::List.find_changes(client, list_query)

      index = 0
      while index < 1 || index > changes.size
        range = changes.size == 1 ? '' : "(1 - #{changes.size})"
        index = ui.ask("Which change would you like to submit? #{range} ")
                  .argument(:required)
                  .read_int
      end

      submit_change(changes[index - 1])
    end

    private

    def submit_change(change)
      p = Pastel.new
      description = p.cyan("#{change['subject']}") + p.green(" (##{change['number']})")
      ui.spinner("Submitting #{description}...") do
        ui.print(client.execute(%W[review change:#{change['number']} --submit]))
      end
    end
  end
end
