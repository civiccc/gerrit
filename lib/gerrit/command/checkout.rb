module Gerrit::Command
  # Check out a patchset locally.
  class Checkout < Base
    def execute
      result = spawn(%W[git fetch #{repo.remote_url} #{change_refspec}])
      if result.success?
        spawn(%w[git checkout FETCH_HEAD])
      end
    end

    private

    # Returns the latest refspec for the given change number.
    def change_refspec
      change_md = change_metadata
      change_number = change_md['number']
      patchset = change_md['currentPatchSet']['number']

      # Gerrit takes the last two digits of the change number to nest under a
      # directory with that name so they don't exceed the per-directory file limit
      prefix = change_number.rjust(2, '0').to_s[-2..-1]

      "refs/changes/#{prefix}/#{change_number}/#{patchset}"
    end

    def change_metadata
      change_num_or_id =
        if arguments[1]
          arguments[1]
        else
          ui.ask('Enter change number or Change-ID').argument(:required).read_string
        end

      client.change(change_num_or_id)
    end
  end
end
