module Gerrit::Command
  # Show a list of changes matching a specified query.
  class List < Base
    def execute
      # Get changes ordered from newest to oldest
      changes =
        ui.spinner('Loading ') do
          client.query_changes(query).sort_by { |change| -change['lastUpdated'] }
        end

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
