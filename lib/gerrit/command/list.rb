module Gerrit::Command
  # Show a list of changes matching a specified query.
  class List < Base
    def execute
      changes = ui.spinner('Loading ') { self.class.find_changes(client, query) }

      # Display changes in reverse order so that the newest are at the bottom of
      # the table (i.e. the part that will be visible in a console when there is
      # a long list)
      ui.table(header: %w[# CR V Subject Owner Project Updated],
               alignments: [:left, :center, :center, :left, :left, :left, :right],
               padding: [0,1,0,1]) do |t|
        changes.each_with_index.map do |change, index|
          [
            index + 1,
            symbol_for_status('Code-Review', change),
            symbol_for_status('Verified', change),
            change['subject'],
            change['owner']['name'],
            change['project'],
            human_time(Time.at(change['lastUpdated'])),
          ]
        end.reverse.each do |row|
          t << row
        end
      end
    end

    # HACK: We cache the results of this since we may want to reuse the result
    # of the query in other commands (see Command::Submit for an example).
    # We also make this a public class method so other commands can call it.
    def self.find_changes(client, search_query)
      @matching_changes ||= {}
      @matching_changes[search_query] =
        client.query_changes(search_query).sort_by { |change| -change['lastUpdated'] }
    end

    private

    def query
      if arguments[1]
        arguments[1]
      else
        'status:open' # Show all open changes by default
      end
    end

    def label_status(label_name, change)
      status = change.fetch('submitRecords', []).first
      return unless status

      label_status = status['labels'].find { |label| label['label'] == label_name }
      return unless label_status

      label_status['status']
    end

    def symbol_for_status(label_name, change)
      p = Pastel.new

      value = label_status(label_name, change)
      case value
      when 'REJECT'
        p.red.bold('✕')
      when 'OK'
        p.green.bold('✓')
      else
        ''
      end
    end
  end
end
